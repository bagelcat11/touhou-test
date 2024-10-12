shader_type canvas_item;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 c = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgba;
	c.r = 1.0 - c.r;
	c.g = 1.0 - c.g;
	c.b = 1.0 - c.b;
	COLOR.rgba = c;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
