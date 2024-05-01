extends Node3D
class_name CameraControl

@export var target : Node3D
@export var camera : Camera3D
@export var shaderQuad : MeshInstance3D
@export var rotationSpeed : float = 60
@export var interior : bool = false

var origTarget : Node3D
var lastTarget : Node3D
var currRotation : Vector3

func _ready():
	shaderQuad.visible = !interior
	origTarget = target
	lastTarget = target
	Global.Camera = self
	if(target != null): position = target.position
	currRotation = global_rotation_degrees
	currRotation.y = Global.State.cameraAngle
	global_rotation_degrees = currRotation
	var window = get_window()
	updateScreenSize(window.content_scale_size)

func _enter_tree():
	Global.Config.onScreenSizeChange.connect(updateScreenSize)
func _exit_tree():
	Global.Config.onScreenSizeChange.disconnect(updateScreenSize)

var _panPerc:float = 0.0
var _panTime:float = 0.0
var _panStartPos:Vector3 = Vector3(0,0,0)

func panTowards(newTarget:Node3D, time:float):
	if newTarget != lastTarget:
		lastTarget = target
		target = newTarget
	_panTime = time
	_panPerc = 0.0
	_panStartPos = lastTarget.global_position
func resetTarget(time:float):
	panTowards(origTarget,time)
func isPanning():
	return lastTarget != target

func _process(delta):
	if(target != null): 
		if lastTarget==target:
			global_position = target.global_position
		else:
			global_position = lerp(_panStartPos, target.global_position, _panPerc)
			_panPerc += delta / _panTime
			if _panPerc >= 1:
				lastTarget = target
	#
	var _cr = global_rotation_degrees
	_cr.x = moveTowardsAngle(_cr.x, currRotation.x, rotationSpeed * delta)
	_cr.y = moveTowardsAngle(_cr.y, currRotation.y, rotationSpeed * delta)
	_cr.z = moveTowardsAngle(_cr.z, currRotation.z, rotationSpeed * delta)
	global_rotation_degrees = _cr
	if (_cr == currRotation):
		var axis = roundf(getHorz())
		if axis != 0:
			rotateTowardsY(_cr.y + (axis * 45))

func getHorz():
	if !canMove(): return 0
	return Input.get_axis("cam_left", "cam_right")

func canMove():
	if Global.Ev.isBusy(): return false
	if Global.UI.busy(): return false
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

func updateScreenSize(newSize:Vector2i):
	camera.size = newSize.y * Global.PIXEL_SIZE
	camera.fov = newSize.y * Global.PIXEL_FOV

func setLayers(l:int):
	camera.cull_mask = l
