extends Area3D

@export var parentVehicle:Vehicle
@export var moveNode:Node3D
@export var minMaxPos:Vector2
@export var moveSpeed:float = 3

var bodiesInsideArea:Array = []
var oldPosition:Vector3
var oldRotation:Vector3

func _ready():
	await get_tree().process_frame
	oldPosition = global_position
	oldRotation = global_rotation

func _process(delta):
	if parentVehicle.mountedCharacter == null:
		return
	if !parentVehicle.canMove():
		return
	var move = Input.get_axis("cycle_right","cycle_left") * moveSpeed
	var newPos = move_toward(moveNode.position.y, moveNode.position.y + move, delta*moveSpeed)
	moveNode.position.y = clamp(newPos, minMaxPos.x, minMaxPos.y)
	# Update bodies position (only when fork is high enough)
	if moveNode.position.y > 0:
		var deltaPos = global_position - oldPosition
		var deltaRot = global_rotation - oldRotation
		for b in bodiesInsideArea:
			var oldOffset = oldPosition - b.global_position
			var oldOffRot = oldOffset.rotated(Vector3.RIGHT, deltaRot.x).rotated(Vector3.UP, deltaRot.y).rotated(Vector3.FORWARD, deltaRot.z)
			var deltaOff = oldOffset-oldOffRot
			b.global_position += deltaPos + deltaOff
			b.global_rotation += deltaRot
	oldPosition = global_position
	oldRotation = global_rotation

func _on_body_entered(body):
	if body is RigidBody3D:
		if !bodiesInsideArea.has(body):
			bodiesInsideArea.append(body)

func _on_body_exited(body):
	if body is RigidBody3D:
		if bodiesInsideArea.has(body):
			bodiesInsideArea.erase(body)
