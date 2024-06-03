@tool
extends Sprite3D

func _ready():
	_updateFlip()

func _process(delta):
	_updateFlip()

func _updateFlip():
	var shMat = material_override as ShaderMaterial
	shMat.set_shader_parameter(&"flip_h", _resolveFlip())

func _resolveFlip():
	var angle : float = global_rotation_degrees.y
	var cam = get_viewport().get_camera_3d()
	if (cam != null): angle -= cam.global_rotation_degrees.y
	if angle >= 360: angle -= 360
	if angle < 0: angle += 360
	return angle < 180
