extends CharacterBody3D

@export var refBody : Node3D
@export var cast : RayCast3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
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

func get_inputdir():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _ready():
	alignWithBody()

func _process(delta):
	alignWithBody()
	if Input.is_action_just_pressed("action_ok"):
		_dirIdx = (_dirIdx+1) % 6
	var dir = get_inputdir()
	if dir:
		global_position += Vector3(dir.x,0,dir.y) * delta

func _physics_process(delta):
	return
	# Get direction towards "center"
	var gravityDirection = (global_position - refBody.global_position).normalized()
	
	# Add the gravity.
	currentNormal = cast.get_collision_normal()
	
	if not cast.is_colliding():
		print("Not colliding")
		gravityVelocity -= gravityDirection * GRAVITY * delta
	else:
		# Handle jump. # No jump for now, probably never in worldmap cuz yes.
		if Input.is_action_just_pressed("action_extra"):
			print("JUMP?")
			gravityVelocity = gravityDirection
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if input_dir:
		var up = -transform.basis.y
		var left = -transform.basis.x
		movementVelocity = ((up * input_dir.y) - (left * input_dir.x)).normalized() * SPEED
	else:
		movementVelocity.x = move_toward(movementVelocity.x, 0, SPEED)
		movementVelocity.y = move_toward(movementVelocity.y, 0, SPEED)
		movementVelocity.z = move_toward(movementVelocity.z, 0, SPEED)
	
	velocity = gravityVelocity + movementVelocity
	print(velocity)
	
	move_and_slide()

func align_with_y(xform, new_y):
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
