void main() {
	float4 color;

	float border_x = width/GetResolution().x;
	float border_y = width/GetResolution().y;

	if (v_tex0.x <= border_x
			|| v_tex0.x >= 1.0-border_x
			|| v_tex0.y <= border_y
			|| v_tex0.y >= 1.0-border_y) {
		color = float4(1.0, 1.0, 1.0, 1.0);
	} else {
		color = Sample();
	}

  SetOutput(color);
}
