extends MeshInstance3D

@export var switchId:int = 0
@export var moveSpeed:float = 1
@export var rotSpeed:float = 1
@export var positions:Array[Node3D]
@export var waitAfterMove:float = 0.0

var currIdx = 0
var cooldown = 0

func _ready():
	global_position = positions[0].global_position
	global_rotation = positions[0].global_rotation

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
		return
	
	if switchId >= 0:
		var switch = Global.State.getSwitch(switchId)
		if !switch: currIdx = 0
	
	var nextPos = positions[currIdx]
	var oldPos = global_position
	var oldRot = global_rotation
	global_position = global_position.move_toward(nextPos.global_position, delta*moveSpeed);
	global_rotation = global_rotation.move_toward(nextPos.global_rotation, delta*rotSpeed);
	var deltaPos = global_position - oldPos
	var deltaRot = global_rotation - oldRot
	for body in bodiesOnPlatform:
		var oldOffset = oldPos - body.global_position
		var oldOffRot = oldOffset.rotated(Vector3.RIGHT, deltaRot.x).rotated(Vector3.UP, deltaRot.y).rotated(Vector3.FORWARD, deltaRot.z)
		var deltaOff = oldOffset-oldOffRot
		body.global_position += deltaPos + deltaOff
		body.global_rotation += deltaRot
		pass
	if nextPos.global_position == global_position:
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
