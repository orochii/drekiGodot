shader_type spatial;
render_mode unshaded,cull_front;

uniform sampler2D tex:source_color,filter_nearest;

uniform vec4 albedo_color = vec4(1.0);
uniform bool flip_h = false;
uniform float scale = 1.0;
uniform float rotation = 0.0;

void vertex(){
	float sine = sin(rotation - PI/2.0) * scale;
	float cosine = cos(rotation - PI/2.0) * scale;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	MODELVIEW_MATRIX[0][0] *= sine;
	MODELVIEW_MATRIX[0][1] += cosine;
	MODELVIEW_MATRIX[1][0] += cosine;
	MODELVIEW_MATRIX[1][1] *= -sine;

}

void fragment(){
	vec2 uv = UV;
	//if (flip_h) uv.x = 1.0-uv.x;
	vec4 tex_samp = texture(tex,uv);
	ALBEDO = tex_samp.rgb * albedo_color.rgb;
	ALPHA = tex_samp.a * albedo_color.a;
}