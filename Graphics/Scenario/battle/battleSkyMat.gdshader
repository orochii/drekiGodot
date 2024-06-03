shader_type spatial;
render_mode unshaded,shadows_disabled;

uniform vec4 tintColor : source_color = vec4(1,1,1,1);
uniform vec4 bottomColor : source_color;
uniform vec4 middleColor : source_color;
uniform vec4 topColor : source_color;
uniform float bottomStart;
uniform float middleStart;
uniform float middleEnd;
uniform float topStart;
uniform float topEnd;

float inverseLerp(float v, float minV, float maxV) {
	float _v = v - minV;
	float _m = maxV - minV;
	return _v / _m;
}

void fragment() {
	vec4 vertex = INV_VIEW_MATRIX * vec4(VERTEX, 1.0);
	
	float _y = vertex.y;
	if (_y < bottomStart) {
		ALBEDO = bottomColor.rgb;
	} else if (_y < middleStart) {
		float _v = inverseLerp(_y, bottomStart,middleStart);
		ALBEDO = mix(bottomColor, middleColor, _v).rgb;
	} else if (_y < middleEnd) {
		ALBEDO = middleColor.rgb;
	} else if (_y < topStart) {
		float _v = inverseLerp(_y, middleEnd,topStart);
		ALBEDO = mix(middleColor, topColor, _v).rgb;
	} else if (_y < topEnd) {
		float _v = inverseLerp(_y, topStart,topEnd);
		ALBEDO = mix(topColor, middleColor, _v).rgb;
	} else {
		ALBEDO = middleColor.rgb;
	}
	ALBEDO = ALBEDO * tintColor.rgb;
}