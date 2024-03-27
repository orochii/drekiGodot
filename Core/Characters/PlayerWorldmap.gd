extends RigidBody3D

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

var gravityVelocity : Vector3
var movementVelocity : Vector3
var moveNode : Node3D

func _ready():
	alignWithBody()
	moveNode = $MoveNode

func _integrate_forces(state):
	alignWithBody()
	# Get direction towards "center"
	var gravityDirection = (global_position - refBody.global_position).normalized()
	var normalDir = -gravityDirection
	var g = -gravityDirection * state.step * GRAVITY
	state.linear_velocity += g
	if cast.is_colliding():
		normalDir = cast.get_collision_normal()
		if normalDir.dot(gravityDirection) >= 0.0:
			normalDir = normalDir * -1
	moveNode.global_transform = align_with_y(moveNode.global_transform, -normalDir)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		# rotate
		input_dir = input_dir.rotated(-yRefNode.rotation.y)
		graphicNode.rotation_degrees.y = rad_to_deg(input_dir.angle())
		#
		var f = moveNode.global_transform.basis.z
		var r = moveNode.global_transform.basis.x
		var move = (f*input_dir.y + r*input_dir.x).normalized() * get_speed()
		if state.linear_velocity.length_squared() < get_maxspeed()*get_maxspeed():
			state.apply_force(move)
		#movementVelocity = move
	#else:
	#	movementVelocity.x = move_toward(movementVelocity.x, 0, SPEED)
	#	movementVelocity.y = move_toward(movementVelocity.y, 0, SPEED)
	#	movementVelocity.z = move_toward(movementVelocity.z, 0, SPEED)
	
	#state.linear_velocity = gravityVelocity + movementVelocity

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
