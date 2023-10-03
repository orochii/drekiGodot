extends CharacterBody3D
class_name Character

const JUMP : float = 20
const AVG_SPEED : float = 15
const fall_acceleration : float = 98

@export var speed = AVG_SPEED
@export var speedMult = 1
@export var graphic : CharGraphic
@export var state : StringName = &"base"
var target_velocity = Vector3.ZERO
var grounded : bool = false

func setMove(direction : Vector3):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		look_at(position - direction, Vector3.UP)
	var mspeed = speed * getSpeedMult()
	target_velocity.x = direction.x * mspeed
	target_velocity.z = direction.z * mspeed

func jump():
	if is_on_floor():
			target_velocity.y = JUMP

func _physics_process(delta):
	grounded = is_on_floor()
	if not grounded: # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		if target_velocity.y < 0: target_velocity.y = 0
	
	velocity = target_velocity
	if graphic != null:
		graphic.speed = velocity.length() / AVG_SPEED
		graphic.state = getCurrentState()
	move_and_slide()

func getCurrentState():
	if state == &"base":
		if !grounded:
			return &"jump"
		if graphic.speed >= 1.1:
			return &"run"
	return state

func getSpeedMult():
	return speedMult
