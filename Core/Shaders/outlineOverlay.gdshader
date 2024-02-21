shader_type spatial;
render_mode unshaded;

// TODO:
// Fix y-scale. Seems like it's ignoring it :V.
// Set the right texture to the sprite's one.

uniform vec4 color : source_color;
uniform float yScale = 1.0;
uniform sampler2D texture : source_color, filter_nearest;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;

varying float cachedDepth;

void vertex() {
	// Called for every vertex the material is visible on.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	MODELVIEW_MATRIX[1][1] = yScale;
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 d = texture(DEPTH_TEXTURE, SCREEN_UV);
	vec4 s = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec4 c = texture(texture, UV);
	ALBEDO = color.rgb;
	ALPHA = 0.0;
	//if (d.r >= DEPTH) {
	//if (c.a >= 0.5 && c != s) {
	//	ALBEDO = s.rgb;
	//	ALPHA = 0.3;
	//	DEPTH = 0.0;
	//}
	ALBEDO = c.rgb;
	ALPHA = c.a * 0.3;
	DEPTH = 0.0;
	//DEPTH = 0.0;
}

void light() {
	// Called for every pixel for every light affecting the material.
}
