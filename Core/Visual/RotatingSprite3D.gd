@tool
extends Sprite3D
class_name RotatingSprite3D

@export var rotationZ:float = 0
@export var rawOffset:Vector2i = Vector2i()

func _ready():
	__updateValues()

func _process(delta):
	if Engine.is_editor_hint():
		__updateValues()

#sprite.offset = Vector2(_gripOff.x, _gripOff.y)
#sprite.rawOffset = -_posOff
#sprite.flip_h = flipH
#sprite.rotationZ = rotZ

func setVals(_off:Vector2i,_raw:Vector2i,_rotZ:float,_flipH:bool):
	offset = _off
	rawOffset = _raw
	rotationZ = _rotZ
	flip_h = _flipH
	__updateValues()

func __updateValues():
	var rawOffsetScaled = Vector2(rawOffset.x, rawOffset.y) * pixel_size
	var p = material_override
	p.set_shader_parameter("tex", texture)
	p.set_shader_parameter("albedo_color", modulate)
	p.set_shader_parameter("flip_h", flip_h)
	p.set_shader_parameter("scale", scale.z)
	p.set_shader_parameter("rotation", rotationZ)
	p.set_shader_parameter("raw_offset", rawOffsetScaled)
