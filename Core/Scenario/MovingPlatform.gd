extends Node

@export var targetNodePath:NodePath
@export var switchId:StringName = &""
@export var moveSpeed:float = 1
@export var rotSpeed:float = 1
@export var positions:Array[Node3D]
@export var waitAfterMove:float = 0.0

var targetNode
var currIdx = 0
var cooldown = 0

func _ready():
	targetNode = get_node(targetNodePath)
	targetNode.global_position = positions[0].global_position
	targetNode.global_rotation = positions[0].global_rotation

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		return
	
	if switchId != &"":
		var switch = Global.State.getSwitch(switchId)
		if !switch: currIdx = 0
	
	var nextPos = positions[currIdx]
	var oldPos = targetNode.global_position
	var oldRot = targetNode.global_rotation
	targetNode.global_position = targetNode.global_position.move_toward(nextPos.global_position, delta*moveSpeed);
	targetNode.global_rotation = targetNode.global_rotation.move_toward(nextPos.global_rotation, delta*rotSpeed);
	var deltaPos = targetNode.global_position - oldPos
	var deltaRot = targetNode.global_rotation - oldRot
	for body in bodiesOnPlatform:
		var oldOffset = oldPos - body.global_position
		var oldOffRot = oldOffset.rotated(Vector3.RIGHT, deltaRot.x).rotated(Vector3.UP, deltaRot.y).rotated(Vector3.FORWARD, deltaRot.z)
		var deltaOff = oldOffset-oldOffRot
		body.global_position += deltaPos + deltaOff
		body.global_rotation += deltaRot
	if nextPos.global_position == targetNode.global_position:
		currIdx = (currIdx + 1) % positions.size()
		cooldown = waitAfterMove

# ===  ===
var bodiesOnPlatform:Array[Node3D] = []

func _on_area_3d_body_entered(body):
	if body is PhysicsBody3D:
		if body is StaticBody3D:
			pass
		else:
			if bodiesOnPlatform.has(body): return
			else:
				bodiesOnPlatform.append(body)

func _on_area_3d_body_exited(body):
	if body is PhysicsBody3D:
		if body is StaticBody3D:
			pass
		else:
			if bodiesOnPlatform.has(body):
				bodiesOnPlatform.erase(body)
			else:
				return
