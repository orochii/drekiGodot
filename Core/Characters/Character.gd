extends CharacterBody3D
class_name Character

@export var speed = 14
@export var fall_acceleration = 75

const JUMP :float = 15
var target_velocity = Vector3.ZERO

func setMove(direction : Vector3):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		look_at(position + direction, Vector3.UP)
		
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

func jump():
	if is_on_floor():
			target_velocity.y = JUMP

func _physics_process(delta):
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		if target_velocity.y < 0: target_velocity.y = 0
	
	velocity = target_velocity
	move_and_slide()
