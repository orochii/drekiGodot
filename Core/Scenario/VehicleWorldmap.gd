extends CharacterWorldmap
class_name VehicleWorldmap

@export_group("References")
@export var refBody : Node3D
@export var worldmapCamera : CameraWorldmap
@export var graphicNode : Node3D
@export var cast : RayCast3D
@export var moveNode : Node3D
@export var positionIndicator : Node3D
@export_group("Behaviour")
@export var requireItem:BaseItem = null
@export var mountedCharacter:PlayerWorldmap = null
@export var attachPoint:Node3D = null
@export var bodyExceptions:Array[PhysicsBody3D]
@export_group("Movement")
@export var speedForce = 150.0
@export var dashForceMult = 1.5
@export var maxWalkSpeed = 20.0
@export var maxDashSpeed = 30.0
@export var rotationSpeed = 60.0
@export var heightMinMax:Vector2 = Vector2(100,250)
@export_group("Audiovisual")
@export var startEngine:AudioStreamPlayer3D
@export var endEngine:AudioStreamPlayer3D
@export var ui:Control
@export var interactOffset:float = 2.0
@export var animTree:AnimationTree
var currRot:float = 0
var currSpeed:float = 0
var currHeight:float = 0

func onInteract():
	if requireItem != null:
		if !Global.State.party.hasItem(requireItem.getId()):
			return
	mount(Global.Player)

func mount(character:PlayerWorldmap):
	character.graphicNode.speed = 0
	character.forcedMove = true
	character.linear_velocity = Vector3()
	character.freeze = true
	startEngine.pitch_scale = 1
	startEngine.play()
	endEngine.stop()
	var _tween = get_tree().create_tween()
	_tween.tween_property(character, "global_position", attachPoint.global_position, 1)
	await get_tree().create_timer(1).timeout
	setCamera()
	mountedCharacter = character
	ui.visible = true
	positionIndicator.visible = false

func unmount():
	if mountedCharacter != null:
		var _pos = cast.get_collision_point()
		ui.visible = false
		positionIndicator.visible = true
		var prevChar = mountedCharacter
		unsetCamera()
		mountedCharacter = null
		startEngine.stop()
		endEngine.play()
		_resetSpeed()
		var _tween = get_tree().create_tween()
		_tween.tween_property(prevChar, "global_position", _pos, 1)
		await get_tree().create_timer(1).timeout
		prevChar.global_position = _pos
		prevChar.forcedMove = false
		prevChar.freeze = false

func setCamera():
	worldmapCamera.target = self
func unsetCamera():
	worldmapCamera.target = mountedCharacter

func _ready():
	ui.visible = false
	setAnimation(Vector3())
	currHeight = getCurrHeight()
	for b in bodyExceptions:
		add_collision_exception_with(b)

func getCurrHeight():
	return global_position.distance_to(refBody.global_position)

func _isDropPointValid(_ref_normal:Vector3):
	if cast.is_colliding():
		# Check if collider allows to be landed on.
		var _collider = cast.get_collider()
		if _collider.has_meta("cannot_land"):
			return false
		# Check if normal is valid.
		var _normal = cast.get_collision_normal()
		var _angle = rad_to_deg(_normal.angle_to(_ref_normal))
		if absf(absf(_angle) - 180) < 15:
			return true
	return false

func _resetSpeed():
	currRot = 0
	currSpeed = 0
	linear_velocity = Vector3()

func _integrate_forces(state):
	alignWithBody()
	# Get direction towards "center"
	var _height = getCurrHeight()
	var gravityDirection = (global_position - refBody.global_position).normalized()
	var normalDir = -gravityDirection
	# Align move node
	moveNode.global_transform = align_with_y(moveNode.global_transform, -normalDir)
	moveNode.rotation.y = graphicNode.rotation.y
	if mountedCharacter != null:
		# Unmount
		if Input.is_action_just_pressed("action_cancel"):
			if _isDropPointValid(normalDir) == true:
				unmount()
				return
		# Raise/lower
		var input_dir = Vector3(getHorz(), getVert(),getLift())
		var _lift = input_dir.z * 20
		currHeight = clampf(currHeight+_lift*state.step, heightMinMax.x, heightMinMax.y)
		# Accel/deaccel and rotate
		currRot = move_toward(currRot, rotationSpeed, state.step * 30.0)
		graphicNode.rotation_degrees.y -= (state.step * currRot * input_dir.x)
		currSpeed = move_toward(currSpeed, -input_dir.y * get_speed(), state.step * 75.0)
		# Audiovisuals
		setAnimation(input_dir)
		startEngine.pitch_scale = remap(abs(currSpeed),0,maxDashSpeed,1,1.5)
		# Move vehicle
		var f = moveNode.global_transform.basis.z
		state.linear_velocity = f * currSpeed
		state.linear_velocity -= gravityDirection * (_height-currHeight)
		# 
		mountedCharacter.global_position = attachPoint.global_position	
	else:
		setAnimation(Vector3())

func alignWithBody():
	var gravityDirection = (global_position - refBody.global_position).normalized()
	global_transform = align_with_y(global_transform, gravityDirection)

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func getHorz():
	if !canMove(): return 0
	return Input.get_axis("move_left", "move_right")

func getVert():
	if !canMove(): return 0
	var f = Input.get_axis("move_up", "move_down")
	if f > 0: f/=2
	return f

func getLift():
	return Input.get_axis("cycle_left", "cycle_right")

func canMove():
	if Global.Ev.isBusy(): return false
	if Global.UI.busy(): return false
	return true

func setAnimation(input:Vector3):
	animTree["parameters/direction/blend_position"] = lerp(animTree["parameters/direction/blend_position"],Vector2(input.x, input.z),0.5)
	animTree["parameters/move/blend_amount"] = lerp(animTree["parameters/move/blend_amount"], -input.y, 0.5)
	animTree["parameters/forward_speed/blend_amount"] = clamp(abs(currSpeed / speedForce)-1, 0.0, 1.0)

func getInteractOffset():
	return interactOffset

func get_speed():
	if get_dash():
		return speedForce * dashForceMult
	return speedForce

func get_maxspeed():
	if get_dash():
		return maxDashSpeed
	return maxWalkSpeed

func get_dash():
	return Input.is_action_pressed("action_run")
