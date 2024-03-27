shader_type canvas_item;

uniform bool fakeEffect;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	if (fakeEffect == true) {
		vec4 c = texture(TEXTURE, UV);
		vec4 modulate = COLOR / c;
		COLOR = vec4(0,0,0,c.r);
	} else {
		/*vec3 s = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
		vec4 c = texture(TEXTURE, UV);
		vec4 modulate = COLOR / c;
		float a = c.r * c.g * c.b * c.a;
		vec4 i = vec4(s.r-c.r, s.g-c.g, s.b-c.b, a);
		COLOR = i * modulate;*/
	}
}
