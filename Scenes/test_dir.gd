extends CSGSphere3D

@export var character:Node3D
@export var range:float = 3
@export var viewAngle:float = 45
@export var normalMat:Material
@export var seenMat:Material

func _process(delta):
	var move = Input.get_vector("move_left","move_right","move_up","move_down")
	global_position += Vector3(move.x,0,move.y)*delta*10
	set_mat(_canSee(self))

func _canSee(p:Node3D):
	if p != null:
		var distSq = character.global_position.distance_squared_to(p.global_position)
		if (distSq < range*range):
			# check direction angle
			var rot = character.global_rotation
			var dir = p.global_position - character.global_position
			var dirRot = dir.rotated(Vector3.RIGHT, -rot.x).rotated(Vector3.UP, -rot.y).rotated(Vector3.FORWARD, -rot.z)
			var angle = dir.angle_to(Vector3.BACK)
			if angle < deg_to_rad(viewAngle):
				return true
	return false

func set_mat(v:bool):
	if v:
		material = seenMat
	else:
		material = normalMat
