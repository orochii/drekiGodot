extends CharacterBody3D

@export var refBody : Node3D
@export var cast : RayCast3D

const SPEED = 5.0
const JUMP_VELOCITY = 10.0
const GRAVITY = 98.0

var gravityVelocity : Vector3
var movementVelocity : Vector3
var currentNormal : Vector3

var _dirIdx = 0
var DIRECTIONS = [Vector3.UP, Vector3.DOWN, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

func alignWithBody():
	#look_at(refBody.global_position, Vector3.UP)
	var gravityDirection = (global_position - refBody.global_position).normalized()
	global_transform = align_with_y(global_transform, gravityDirection)

func get_dash():
	return Input.is_action_pressed("action_run")

func get_inputdir():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _ready():
	alignWithBody()

func _process(delta):
	alignWithBody()

func _physics_process(delta):
	# Get direction towards "center"
	var gravityDirection = (global_position - refBody.global_position).normalized()
	
	# Add the gravity.
	if not cast.is_colliding():
		gravityVelocity -= gravityDirection * GRAVITY * delta
	else:
		gravityVelocity = Vector3.ZERO
		# Handle jump. # No jump for now, probably never in worldmap cuz yes.
		if Input.is_action_just_pressed("action_extra"):
			gravityVelocity = gravityDirection * JUMP_VELOCITY
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		var f = global_transform.basis.z
		var r = transform.basis.x
		movementVelocity = (f*input_dir.y + r*input_dir.x).normalized() * get_speed()
		print(movementVelocity)
	else:
		movementVelocity.x = move_toward(movementVelocity.x, 0, SPEED)
		movementVelocity.y = move_toward(movementVelocity.y, 0, SPEED)
		movementVelocity.z = move_toward(movementVelocity.z, 0, SPEED)
	
	velocity = gravityVelocity + movementVelocity
	
	move_and_slide()

func get_speed():
	if get_dash():
		return SPEED * 4
	return SPEED

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
