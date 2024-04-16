shader_type spatial;

uniform vec3 mainColor1 : source_color;
uniform vec3 mainColor2 : source_color;
uniform vec3 detailColor : source_color;
uniform vec3 fresnelColor : source_color;
uniform float colorSteps = 16.0;
uniform float magnitude = 0.01;
uniform float timeScale = 0.01;
uniform sampler2D mainTex : source_color,filter_nearest;
uniform sampler2D detailTex1 : source_color,filter_nearest;
uniform sampler2D detailTex2 : source_color,filter_nearest;

uniform float edge_scale = 0.1;
uniform float near = 0.5;
uniform float far = 100.0;
uniform vec3 edge_color : source_color;

//uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
//uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float fresnel(float amount, vec3 normal, vec3 view) {
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
float edge(float depth) {
	depth = 2.0 * depth - 1.0;
	return near * far / (far + depth * (near - far));
}
float grad(float v, float s) {
	int steps = int(v * s);
	float value = float(steps) / s;
	return value;
}

void vertex() {
	// Called for every vertex the material is visible on.
	vec4 c = texture(mainTex, UV + vec2(TIME*timeScale));
	float x = sin(TIME + c.r);
	float y = cos(c.r);
	vec3 d = normalize(VERTEX);
	VERTEX += d * magnitude * (x+y);
}

void fragment() {
	vec2 uv = UV + vec2(TIME*timeScale);
	vec4 c = texture(mainTex, uv);
	float fresnel = fresnel(5.0, NORMAL, VIEW);
	vec3 mainColor = mix(mainColor1, mainColor2, c.r);
	vec4 cd1 = texture(detailTex1, uv*10.0 + sin(TIME)*0.01);
	vec4 cd2 = texture(detailTex2, uv*20.0 + cos(TIME+1.0)*0.02);
	vec4 cd = cd1 * cd2;
	vec3 cc = mix(mainColor, detailColor, cd.r);
	vec3 total = mix(cc, fresnelColor, fresnel);
	if (colorSteps > 0.0) {
		total.r = grad(total.r, colorSteps);
		total.g = grad(total.g, colorSteps);
		total.b = grad(total.b, colorSteps);
	}
	ALBEDO = total;
}
