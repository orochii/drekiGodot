shader_type canvas_item;

uniform sampler2D fadeTexture;
uniform float threshold : hint_range(0.0, 1.0) = 1;

void fragment() {
	vec4 alphaColor = texture(fadeTexture, UV);
	vec4 pixelColor = texture(TEXTURE, UV);
	pixelColor.a = ((threshold * 2.0) - alphaColor.r);
	COLOR = pixelColor; //vec4(UV.r,UV.g,0,1);
}
