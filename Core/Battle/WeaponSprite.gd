@tool
extends Node3D
class_name WeaponSprite

@export var sprite: RotatingSprite3D
@export var gripOffset: Vector2i
@export var positionOffset: Vector2i
@export var rotationZ: float
@export var flipH:bool

func _process(delta):
	# Calculate new offset
	if(sprite==null): return
	var rotZ = rotationZ
	var _posOff = positionOffset
	var _gripOff = gripOffset
	
	if(flipH): 
		_posOff.x = -_posOff.x
		_gripOff.x = -_gripOff.x
		rotZ = -rotZ
	var invRotOffset = Vector2(_posOff.x, _posOff.y)
	invRotOffset = invRotOffset.rotated(-rotZ)
	var totalOffset = invRotOffset + Vector2(_gripOff.x, _gripOff.y)
	sprite.offset = totalOffset
	sprite.flip_h = flipH
	sprite.rotation.z = rotZ
	# Face camera
	var cam = get_viewport().get_camera_3d()
	if(cam==null):return
	look_at(cam.global_transform.origin,Vector3(0,1,0))

func setSprite(t:Texture):
	sprite.texture = t
