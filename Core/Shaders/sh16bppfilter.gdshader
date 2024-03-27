shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform int rT = 32;
uniform int gT = 32;
uniform int bT = 32;
uniform int aT = 32;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.0);
	int r8 = int(c.r * 256.0);
	int g8 = int(c.g * 256.0);
	int b8 = int(c.b * 256.0);
	int a8 = int(c.a * 256.0);
	float rR = float(r8 * rT / 256) / float(rT);
	float gR = float(g8 * gT / 256) / float(gT);
	float bR = float(b8 * bT / 256) / float(bT);
	float aR = float(a8 * aT / 256) / float(aT);
	COLOR = vec4(rR,gR,bR,aR);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
