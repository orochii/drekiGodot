shader_type canvas_item;

uniform sampler2D fadeTexture;
uniform float threshold : hint_range(0.0, 1.0) = 1;
uniform bool cutout = false;

void fragment() {
	vec4 alphaColor = texture(fadeTexture, UV);
	vec4 pixelColor = texture(TEXTURE, UV);
	float a = ((threshold * 2.0) - alphaColor.r);
	if (cutout) {
		if (a < 0.5) pixelColor.a = 0.0;
		else pixelColor.a = 1.0;
	} else {
		pixelColor.a = a;
	}
	COLOR = pixelColor; //vec4(UV.r,UV.g,0,1);
}
