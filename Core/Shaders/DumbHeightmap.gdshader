shader_type spatial;

uniform sampler2D noise;
uniform sampler2D normalmap;
uniform float height_scale = 0.5;
uniform float map_scale = 0.5;

varying vec2 vertex_position;

void vertex() {
	vertex_position = VERTEX.xz * map_scale;
	//VERTEX.y += cos(VERTEX.x * 4.0) * sin(VERTEX.z * 4.0);
	float height = texture(noise, vertex_position ).x; //divide by the size of the PlaneMesh
	VERTEX.y += height * height_scale;
}

void fragment() {
	NORMAL_MAP = texture(normalmap, vertex_position).xyz;
	ALBEDO = vec3(0,0,0);
}