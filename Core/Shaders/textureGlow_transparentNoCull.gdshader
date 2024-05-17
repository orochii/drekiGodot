// NOTE: Shader automatically converted from Godot Engine 4.1.1.stable's StandardMaterial3D.

shader_type spatial;
render_mode blend_mix,alpha_to_coverage,cull_disabled,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : source_color;
uniform sampler2D texture_albedo : source_color,filter_nearest_mipmap,repeat_enable;
uniform float point_size : hint_range(0,128);
uniform float roughness : hint_range(0,1);
uniform sampler2D texture_metallic : hint_default_white,filter_nearest_mipmap,repeat_enable;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_roughness_r,filter_nearest_mipmap,repeat_enable;
uniform float specular;
uniform float metallic;
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;
uniform float baseHeight = 0.0;
uniform float fadeDistance = 0.3;
uniform int fadeMultIterations = 0;
uniform bool customEmission = false;
uniform vec4 emissionColor : source_color;

varying float height;

float invLerp(float a, float b, float v) {
	if(v < a) return 0.0f;
	if(v > b) return 1.0f;
	return (v-a)/(b-a);
}

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	height = VERTEX.y;
}

void fragment() {
	ALPHA_SCISSOR_THRESHOLD = 0.5;
	vec3 VERTEX_WORLD = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).rgb;
	float h = VERTEX_WORLD.y;
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	ALPHA = albedo.a * albedo_tex.a;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	vec4 roughness_texture_channel = vec4(1.0,0.0,0.0,0.0);
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	float delta = abs(h-baseHeight);
	float i = 1.0 - invLerp(0.0, fadeDistance, delta);
	float j = i;
	for(int k=0;k<fadeMultIterations;k++) {
		j = j * i;
	}
	i = j;
	if (customEmission) {
		EMISSION = emissionColor.rgb * i;
	} else {
		EMISSION = ALBEDO * i;
	}
}
