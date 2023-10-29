shader_type canvas_item;

uniform sampler2D shinnings;
uniform float shinnings_strength : hint_range(0.0, 1.0, 0.1);
uniform vec4 wire_color1 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 wire_color2 : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float wire_width : hint_range(0.0, 40.0) = 5.0;
uniform float wire_smoothness : hint_range(0.0, 0.1) = 0.01;

varying vec3 barys;
varying vec2 vertex_position;
varying vec2 firstVert;
varying vec2 secondVert;
varying vec2 thirdVert;

void vertex() {
	vertex_position = VERTEX.xy;
	int index = VERTEX_ID % 3;
	switch (index) {
		case 0:
			barys = vec3(1.0, 0.0, 0.0);
			firstVert = vertex_position;
			break;
		case 1:
			barys = vec3(0.0, 1.0, 0.0);
			secondVert = vertex_position;
			break;
		case 2:
			barys = vec3(0.0, 0.0, 1.0);
			thirdVert = vertex_position;
			break;
	}
}

float invLerp(float a, float b, float v) {
	if(v < a) return 0.0f;
	if(v > b) return 1.0f;
	return (v-a)/(b-a);
}

void fragment() {
	float alpha = COLOR.a;
	float y = vertex_position.y;
	if(y > 135.0f) y = 135.0f - (y-135.0f);
	float r = invLerp(0.0f,135.0f,y);
	vec4 shineColor = texture(shinnings, UV);
	float shine_strength = shinnings_strength * shineColor.r * shineColor.g * shineColor.b;
	vec4 wire_color_f = mix(wire_color1, wire_color2, r);
	vec4 wire_color = mix(wire_color_f,shineColor,shine_strength);
	vec4 pixelColor = mix(COLOR,shineColor,shine_strength/4.0f);
	vec3 deltas = fwidth(barys);
	vec3 barys_s = smoothstep(deltas * wire_width - wire_smoothness, deltas * wire_width + wire_smoothness, barys);
	float wires = min(barys_s.x, min(barys_s.y, barys_s.z));
	COLOR = mix(wire_color, pixelColor, wires);
	COLOR.a = alpha;
}
