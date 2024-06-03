shader_type spatial;
render_mode cull_disabled;

uniform sampler2D cloudTexture1 : source_color, filter_nearest;
uniform sampler2D cloudTexture2 : source_color, filter_nearest;
uniform float shadeSteps = 4.0;
uniform float uvScale = 2.0;
uniform float timeScale = 0.001;

void fragment() {
	vec2 uv = UV * uvScale + TIME * timeScale;
	vec4 c1 = texture(cloudTexture1, uv);
	vec4 c2 = texture(cloudTexture2, uv);
	vec4 c3 = c1 * c2;
	int steps = int(c3.r * c3.r * shadeSteps);
	float value = float(steps) / shadeSteps;
	ALPHA = value;
}
