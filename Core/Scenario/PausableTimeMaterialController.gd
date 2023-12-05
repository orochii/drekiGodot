extends MeshInstance3D

var mat:ShaderMaterial
var selfTime:float = 0.0

func _ready():
	mat = mesh.surface_get_material(0)

func _process(delta):
	selfTime += delta
	mat.set_shader_parameter("selfTime", selfTime)
