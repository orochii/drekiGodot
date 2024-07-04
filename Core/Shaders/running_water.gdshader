shader_type spatial;
render_mode unshaded,cull_disabled;

uniform sampler2D waterTexture:source_color,filter_nearest;
uniform float alpha:hint_range(0.0, 1.0, 0.1) = 0.1;
uniform vec2 speed;

void fragment() {
	vec2 d = speed * TIME;
	vec4 c = texture(waterTexture,UV+d);
	ALBEDO = c.rgb;
	ALPHA = alpha;
}
