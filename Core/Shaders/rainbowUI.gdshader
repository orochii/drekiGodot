shader_type canvas_item;

uniform float strength:hint_range(0.0, 1.0, 0.1);
uniform float overlay:hint_range(0.0, 1.0, 0.1);
uniform sampler2D rainbowTexture:source_color,repeat_enable;
uniform vec4 overlayColor:source_color;
uniform vec2 displaceSpeed;
uniform vec2 scale = vec2(1.0,1.0);

void fragment() {
	if (strength > 0.0) {
		vec2 displacement = displaceSpeed * TIME;
		vec2 uv = SCREEN_UV+displacement;
		vec4 _c = texture(rainbowTexture, uv * scale);
		vec4 _rc = COLOR * _c;
		vec4 _oc = COLOR * overlayColor;
		vec4 _sc = mix(COLOR, _rc, strength);
		COLOR = mix(_rc, _oc, overlay);
	}
}
