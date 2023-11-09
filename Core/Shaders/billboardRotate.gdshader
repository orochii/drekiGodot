shader_type spatial;
render_mode unshaded,cull_front;

uniform sampler2D tex:source_color,filter_nearest;

uniform vec4 albedo_color = vec4(1.0);
uniform bool flip_h = false;
uniform vec2 raw_offset = vec2(0.0);
uniform float scale = 1.0;
uniform float rotation = 0.0;
uniform bool yOnly = false;

void vertex(){
	float rot = rotation - PI/2.0;
	float sine = sin(rot) * scale;
	float cosine = cos(rot) * scale;
	if (yOnly) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(vec4(normalize(cross(vec3(0.0, 1.0, 0.0), INV_VIEW_MATRIX[2].xyz)), 0.0), vec4(0.0, 1.0, 0.0, 0.0), vec4(normalize(cross(INV_VIEW_MATRIX[0].xyz, vec3(0.0, 1.0, 0.0))), 0.0), MODEL_MATRIX[3]);
	} else {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	}
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	MODELVIEW_MATRIX[0][0] *= sine;
	MODELVIEW_MATRIX[0][1] += cosine;
	MODELVIEW_MATRIX[1][0] += cosine;
	MODELVIEW_MATRIX[1][1] *= -sine;
	//invRotOffset2.x = (cos(-rotZ)*invRotOffset.x) - (sin(-rotZ)*invRotOffset.y)
	//invRotOffset2.y = (sin(-rotZ)*invRotOffset.x) + (cos(-rotZ)*invRotOffset.y)
	// sin(rotation)*offset.x
	VERTEX.x += sin(rot)*raw_offset.x - cos(rot)*raw_offset.y;
	VERTEX.y += cos(rot)*raw_offset.x + sin(rot)*raw_offset.y;
}

void fragment(){
	vec2 uv = UV;
	//if (flip_h) uv.x = 1.0-uv.x;
	vec4 tex_samp = texture(tex,uv);
	ALBEDO = tex_samp.rgb * albedo_color.rgb;
	ALPHA = tex_samp.a * albedo_color.a;
}