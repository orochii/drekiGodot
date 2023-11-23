shader_type spatial;
//render_mode unshaded;

uniform sampler2D albedoTexture: filter_nearest, source_color;
uniform sampler2D noiseTexture;
uniform float displacement;
uniform float timeScale;
uniform float textureScale = 1.0;
uniform float emissionEnergy = 0.2;

varying vec2 currCoord;

void vertex() {
	currCoord = vec2(VERTEX.x, VERTEX.z);
	vec4 c1 = texture(noiseTexture, UV + (vec2(TIME,TIME)*timeScale));
	vec4 c2 = texture(noiseTexture, UV + (vec2(TIME,TIME)*-timeScale));
	VERTEX.x += c1.r * displacement;
	VERTEX.z += c2.r * displacement;
}

void fragment() {
	// Place fragment code here.
	vec3 c = texture(albedoTexture, currCoord*textureScale).rgb;
	ALBEDO = c;
	EMISSION = c * emissionEnergy;
}
