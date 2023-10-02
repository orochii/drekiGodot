extends Node3D

@export var target : Node3D
@export var camera : Camera3D
@export var rotationSpeed : float = 60

var currRotation : Vector3

func _ready():
	position = target.position
	currRotation = global_rotation_degrees

func _process(delta):
	position = target.position
	var _cr = global_rotation_degrees
	_cr.x = moveTowardsAngle(_cr.x, currRotation.x, rotationSpeed * delta)
	_cr.y = moveTowardsAngle(_cr.y, currRotation.y, rotationSpeed * delta)
	_cr.z = moveTowardsAngle(_cr.z, currRotation.z, rotationSpeed * delta)
	global_rotation_degrees = _cr
	if (_cr == currRotation):
		var axis = getHorz()
		if axis != 0:
			rotateTowardsY(_cr.y + (axis * 45))

func getHorz():
	if !canMove(): return 0
	return Input.get_axis("cam_left", "cam_right")

func canMove():
	if Global.Ev.isBusy(): return false
	if Global.UI.Message.busy(): return false
	return true

func rotateTowards(newRotation : Vector3):
	currRotation = newRotation

func rotateTowardsY(newAngle : float):
	while newAngle >= 180: newAngle -= 360 # <>
	while newAngle < -180: newAngle += 360 # <>
	currRotation.y = newAngle

func moveTowardsAngle(from:float,to:float,delta:float) -> float:
	var d = (to - from)
	var absD = absf(d)
	var r = from
	if (absD > 180):
		r -= 360
		d = (to - r)
		absD = absf(d)
	if delta > absD: delta = absD
	if d > 0:
		r += delta
	else:
		r -= delta
	while r >= 180: r -= 360 # <>
	while r < -180: r += 360 # <>
	return r
