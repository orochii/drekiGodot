extends Node3D
class_name VisualEffect

@export_group("User Position")
@export var userVerticalOffset:float = 0.5
@export var adjustYRot:float = 90
@export var placeAtUser:Array[Node3D]
@export_group("Target Position")
@export var targetPositionYOffset:float = 0
@export var targetVerticalOffset:float = 0.5
@export var followTargets:bool = false
@export_group("Behavior")
@export_range(0,1) var positionLerpValue:float = 1
@export var setupCall:Array[Node]
@export var sendToIsolation:bool = false
@export var done:bool = false
@export var queueForDeletion:bool = false

var _user:Node3D
var _targets = null
var userPos:Vector3
var targetPos:Vector3

func _process(delta):
	for n in placeAtUser:
		n.global_position = _user.global_position
	if _targets != null:
		targetPos = getAvgPosition(_targets) + Vector3(0, targetPositionYOffset, 0)
	self.global_position = getLerpedPosition()
	if queueForDeletion:
		queue_free()

func setup(user:Node3D, targets:Array):
	done = false
	queueForDeletion = false
	_user = user
	if followTargets: _targets = targets
	
	if user is Battler:
		var battler = user as Battler
		if sendToIsolation: 
			battler.battle.addToIsolation(self)
		else:
			user.get_parent().add_child(self)
		userPos = getAvgPosition([battler.graphic])
	else:
		user.get_parent().add_child(self)
		userPos = user.global_position
	targetPos = getAvgPosition(targets) + Vector3(0, targetPositionYOffset, 0)
	for n in placeAtUser:
		n.global_position = _user.global_position
	self.global_rotation_degrees = Vector3(0, user.global_rotation_degrees.y+adjustYRot, 0)
	self.global_position = getLerpedPosition()
	for n in setupCall:
		if n.has_method(&"setup"): n.setup(self,user,targets)

func getAvgPosition(targets:Array):
	var height = 0.0
	var pos = Vector3(0,0,0)
	if targets.size()==0: return pos
	for t in targets:
		pos += t.global_position
		if t is Sprite3D:
			var s = t as Sprite3D
			height += getYOffset(s)
	pos /= targets.size()
	height /= targets.size()
	return pos + Vector3(0,height,0)

func getYOffset(s:Sprite3D):
	var offset = s.offset
	var size = s.texture.get_size()
	if s.region_enabled:
		size = s.region_rect.size
	var min = -size.y/2 + offset.y
	var max = size.y/2 + offset.y
	var offY = lerp(min,max,targetVerticalOffset)
	return offY * s.pixel_size * .5

func getLerpedPosition():
	return lerp(userPos, targetPos, positionLerpValue)
