shader_type spatial;
render_mode cull_disabled;
render_mode unshaded;

void fragment() {
	// Place fragment code here.
	ALBEDO = COLOR.xyz;
	ALPHA = COLOR.a;
}
