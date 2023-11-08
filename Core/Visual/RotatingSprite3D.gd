@tool
extends Sprite3D
class_name RotatingSprite3D

func _ready():
	__updateValues()

func _process(delta):
	__updateValues()

func __updateValues():
	var p = material_override
	p.set_shader_parameter("tex", texture)
	p.set_shader_parameter("albedo_color", modulate)
	p.set_shader_parameter("flip_h", flip_h)
	p.set_shader_parameter("scale", scale.z)
	p.set_shader_parameter("rotation", global_rotation.z)
