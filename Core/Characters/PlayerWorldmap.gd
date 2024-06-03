extends CharacterWorldmap
class_name PlayerWorldmap

@export var refBody : Node3D
@export var cast : RayCast3D
@export var graphicNode : CharGraphic
@export var yRefNode : Node3D

const SPEED_FORCE = 150.0
const DASH_FORCE_MULT = 1.5
const MAX_WALK_SPEED = 20.0
const MAX_DASH_SPEED = 30.0
const JUMP_VELOCITY = 10.0
const GRAVITY = 98.0

var forcedMove :bool
var gravityVelocity : Vector3
var movementVelocity : Vector3
var moveNode : Node3D
var closeEvents : Array

func _ready():
	Global.Player = self
	alignWithBody()
	moveNode = $MoveNode

func _integrate_forces(state):
	alignWithBody()
	if forcedMove: return
	# a
	if getInteract(): interact()
	
	if canMove():
		if Input.is_action_just_pressed("action_menu"):
			Global.Audio.playSFX("decision")
			Global.cacheScreenshot()
			Global.UI.Party.open()
		if Input.is_action_just_pressed("ui_debug"):
			Global.UI.Debug.open()
	# Get direction towards "center"
	var gravityDirection = (global_position - refBody.global_position).normalized()
	var normalDir = -gravityDirection
	var g = -gravityDirection * state.step * GRAVITY
	state.linear_velocity += g
	if cast.is_colliding():
		normalDir = cast.get_collision_normal()
		if normalDir.dot(gravityDirection) >= 0.0:
			normalDir = normalDir * -1
	moveNode.global_rotation = yRefNode.global_rotation
	moveNode.global_transform = align_with_y(moveNode.global_transform, -normalDir)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		# Animation
		graphicNode.speed = 1
		# rotate
		var graphic_dir = input_dir.rotated(-yRefNode.rotation.y)
		graphicNode.rotation_degrees.y = rad_to_deg(graphic_dir.angle())
		#
		var f = moveNode.global_transform.basis.z
		var r = moveNode.global_transform.basis.x
		var move = (f*input_dir.y + r*input_dir.x).normalized() * get_speed()
		if state.linear_velocity.length_squared() < get_maxspeed()*get_maxspeed():
			state.apply_force(move)
	else:
		graphicNode.speed = 0

func alignWithBody():
	var gravityDirection = (global_position - refBody.global_position).normalized()
	global_transform = align_with_y(global_transform, gravityDirection)

func get_dash():
	return Input.is_action_pressed("action_run")

func get_inputdir():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func get_speed():
	if get_dash():
		return SPEED_FORCE * DASH_FORCE_MULT
	return SPEED_FORCE
func get_maxspeed():
	if get_dash():
		return MAX_DASH_SPEED
	return MAX_WALK_SPEED

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

func canMove():
	if forcedMove: return false
	if Global.Ev.isBusy(): return false
	if Global.UI.busy(): return false
	return true

func getInteract():
	if !canMove(): return false
	return Input.is_action_just_pressed("action_ok")

func interact():
	var closestEv = getClosestEv()
	if closestEv != null: closestEv.onInteract()

func getClosestEv():
	var closestEv = null
	var closestDst = 1000000
	for ev in closeEvents:
		if ev is Vehicle || (ev.currentEvent != null && ev.currentEvent.activation==BaseEvent.EActivation.INTERACT):
			var dst = (ev.global_position - global_position).length_squared()
			if dst < closestDst:
				closestEv = ev
				closestDst = dst
	return closestEv

# =============
# Touch/Collide
# =============
func _on_touch_area_entered(area):
	if area is Trigger:
		var trigger = area as Trigger
		trigger.onTouch()

func _on_body_entered(body):
	if body is NPC:
		var npc = body as NPC
		npc.onTouch()

# ========
# Interact
# ========
func _on_area_3d_area_entered(area: Area3D):
	if area is Trigger:
		var trigger = area as Trigger
		if !closeEvents.has(trigger): closeEvents.append(trigger)

func _on_area_3d_area_exited(area: Area3D):
	if area is Trigger:
		var trigger = area as Trigger
		if closeEvents.has(trigger): closeEvents.erase(trigger)

func _on_area_3d_body_entered(body: Node3D):
	if body is NPC:
		var npc = body as NPC
		if !closeEvents.has(npc): closeEvents.append(npc)

func _on_area_3d_body_exited(body: Node3D):
	if body is NPC:
		var npc = body as NPC
		if closeEvents.has(npc): closeEvents.erase(npc)
