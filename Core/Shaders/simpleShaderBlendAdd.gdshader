shader_type spatial;
render_mode cull_disabled,unshaded,blend_add;

uniform sampler2D baseTexture:source_color,filter_nearest;
uniform bool billboard;

void vertex() {
	//UV=UV*uv1_scale.xy+uv1_offset.xy;
	if (billboard) {
		MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
		MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	}
}

void fragment() {
	// Place fragment code here.
	vec4 sample = texture(baseTexture, UV);
	ALBEDO = COLOR.xyz * sample.xyz;
	ALPHA = COLOR.a * sample.a;
}
