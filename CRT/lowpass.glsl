/* This code is ported from the lowpass shader in crt-geom-deluxe,
 * which is included in MAME.
 *
 * MAME is distributed under the General Public License version 2.
 *
 * Original shader by cgwg
 * Ported to Dolphin by Aaron Paden
 */
float3 sample_screen(float2 c)
{
  float2 underscan = step(0.0,c) * step(0.0,float2(1.0, 1.0)-c);
  float3 col = SampleLocation(c).rgb * float3(underscan.x*underscan.y);
  return col;
}

void main() {
	float u_tex_sizex = GetResolution().x;
	float a = 0.5 * u_lowpass_cutoff / u_tex_sizex;
	float b = 0.5 * u_lowpass_width  / u_tex_sizex;
	float w0 = (a-0.5*b);
	float w1 = (a+0.5*b);

	float two_pi = 6.283185307179586;
	float3 n1 = float3(1.0,2.0,3.0);
	float4 n2 = float4(4.0,5.0,6.0,7.0);

  float4 v_lpcoeffs1 = float4(1.0,0.0,0.0,0.0);
  float4 v_lpcoeffs2 = float4(0.0, 0.0, 0.0, 0.0);
	// target frequency response:
	//    1  for w < w0
	//    0  for w > w1
	// linearly decreasing for w0 < w < w1
	// this will be approximated by including the lowest Fourier modes
	if (w0 > 0.5) { // no filtering
		v_lpcoeffs1 = float4(1.0,0.0,0.0,0.0);
		v_lpcoeffs2 = float4(0.0, 0.0, 0.0, 0.0);
	} else if (w1 > 0.5) { // don't reach zero
		// here the target has a nonzero response at the Nyquist frequency
		v_lpcoeffs1.x = w1 + w0 - (w1 - 0.5)*(w1 - 0.5)/(w1 - w0);
		v_lpcoeffs1.yzw = 2.0 / ( two_pi*two_pi*(w1-w0)*n1*n1 ) * ( cos(two_pi*w0*n1) - cos(two_pi*0.5*n1) );
		v_lpcoeffs2     = 2.0 / ( two_pi*two_pi*(w1-w0)*n2*n2 ) * ( cos(two_pi*w0*n2) - cos(two_pi*0.5*n2) );
	} else if (w1 == w0) { // sharp cutoff
		v_lpcoeffs1.x = 2.0 * w0;
		v_lpcoeffs1.yzw = 2.0 / ( two_pi * n1 ) * sin(two_pi*w0*n1);
		v_lpcoeffs2     = 2.0 / ( two_pi * n2 ) * sin(two_pi*w0*n2);
	} else {
		v_lpcoeffs1.x = w1 + w0;
		v_lpcoeffs1.yzw = 2.0 / ( two_pi*two_pi*(w1-w0)*n1*n1 ) * ( cos(two_pi*w0*n1) - cos(two_pi*w1*n1) );
		v_lpcoeffs2     = 2.0 / ( two_pi*two_pi*(w1-w0)*n2*n2 ) * ( cos(two_pi*w0*n2) - cos(two_pi*w1*n2) );
	}

  float onex = 1.0/u_tex_sizex;

  float3 sum = sample_screen(GetCoordinates()) * float3(v_lpcoeffs1.x, v_lpcoeffs1.x, v_lpcoeffs1.x);
  sum +=sample_screen(GetCoordinates()+float2(-1.0*onex,0.0))*float3(v_lpcoeffs1.y, v_lpcoeffs1.y, v_lpcoeffs1.y);
  sum +=sample_screen(GetCoordinates()+float2( 1.0*onex,0.0))*float3(v_lpcoeffs1.y, v_lpcoeffs1.y, v_lpcoeffs1.y);
  sum +=sample_screen(GetCoordinates()+float2(-2.0*onex,0.0))*float3(v_lpcoeffs1.z, v_lpcoeffs1.z, v_lpcoeffs1.z);
  sum +=sample_screen(GetCoordinates()+float2( 2.0*onex,0.0))*float3(v_lpcoeffs1.z, v_lpcoeffs1.z, v_lpcoeffs1.z);
  sum +=sample_screen(GetCoordinates()+float2(-3.0*onex,0.0))*float3(v_lpcoeffs1.w, v_lpcoeffs1.w, v_lpcoeffs1.w);
  sum +=sample_screen(GetCoordinates()+float2( 3.0*onex,0.0))*float3(v_lpcoeffs1.w, v_lpcoeffs1.w, v_lpcoeffs1.w);
  sum +=sample_screen(GetCoordinates()+float2(-4.0*onex,0.0))*float3(v_lpcoeffs2.x, v_lpcoeffs2.x, v_lpcoeffs2.x);
  sum +=sample_screen(GetCoordinates()+float2( 4.0*onex,0.0))*float3(v_lpcoeffs2.x, v_lpcoeffs2.x, v_lpcoeffs2.x);
  sum +=sample_screen(GetCoordinates()+float2(-5.0*onex,0.0))*float3(v_lpcoeffs2.y, v_lpcoeffs2.y, v_lpcoeffs2.y);
  sum +=sample_screen(GetCoordinates()+float2( 5.0*onex,0.0))*float3(v_lpcoeffs2.y, v_lpcoeffs2.y, v_lpcoeffs2.y);
  sum +=sample_screen(GetCoordinates()+float2(-6.0*onex,0.0))*float3(v_lpcoeffs2.z, v_lpcoeffs2.z, v_lpcoeffs2.z);
  sum +=sample_screen(GetCoordinates()+float2( 6.0*onex,0.0))*float3(v_lpcoeffs2.z, v_lpcoeffs2.z, v_lpcoeffs2.z);
  sum +=sample_screen(GetCoordinates()+float2(-7.0*onex,0.0))*float3(v_lpcoeffs2.w, v_lpcoeffs2.w, v_lpcoeffs2.w);
  sum +=sample_screen(GetCoordinates()+float2( 7.0*onex,0.0))*float3(v_lpcoeffs2.w, v_lpcoeffs2.w, v_lpcoeffs2.w);

  SetOutput(float4(sum, 1.0));
}
