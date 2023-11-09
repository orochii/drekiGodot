@tool
extends Node3D
class_name WeaponSprite

@export var sprite: RotatingSprite3D
@export var gripOffset: Vector2i
@export var positionOffset: Vector2i
@export var rotationZ: float
@export var flipH:bool
@export var camOverride:Camera3D

func refreshValues(_positionOffset:Vector2i,_rotationZ:int,_flipH:bool):
	positionOffset = _positionOffset
	rotationZ = _rotationZ
	flipH = _flipH
	refresh()

func refresh():
	if(visible==false): return
	if(sprite==null): return
	# Calculate new offset
	var rotZ:float = deg_to_rad(rotationZ)
	var _posOff = positionOffset
	var _gripOff = gripOffset
	print("WEAP: x%d y%d z%f" % [_posOff.x, _posOff.y, rotZ])
	if(flipH): 
		_posOff.x = -_posOff.x
		_gripOff.x = -_gripOff.x
		rotZ = -rotZ
	var _offset = Vector2(_gripOff.x, _gripOff.y)
	var _rawOffset = -_posOff
	var _flip_h = flipH
	var _rotationZ = rotZ
	sprite.setVals(_offset,_rawOffset,_rotationZ,_flip_h)
	# Face camera
	var cam = camOverride
	if cam==null: cam = get_viewport().get_camera_3d()
	if(cam==null):return
	look_at(cam.global_transform.origin,Vector3(0,1,0))
	#sprite.__updateValues()

#func _process(_delta):
#	refresh()

func setSprite(t:Texture,grip:Vector2i):
	sprite.texture = t
	gripOffset = grip
