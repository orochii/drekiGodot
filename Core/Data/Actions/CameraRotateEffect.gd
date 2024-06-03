extends BaseEffect
class_name CameraRotateEffect

@export_enum("User", "Targets", "Absolute") var target: int
@export var rotationOffset:Vector3
@export var duration:float = 1.0
@export var waitUntilFinished:bool = true

func execute(action:BattleAction):
	var rot = _resolveTargetRotation(action)
	var battle:BattleManager = action.battler.battle
	battle.camera.rotateTo(rot,duration)
	if waitUntilFinished: 
		await battle.get_tree().create_timer(duration).timeout

func _resolveTargetRotation(action:BattleAction):
	match target:
		0:
			return action.battler.rotation + rotDegToRad(rotationOffset)
		1:
			var avg = Vector3()
			for t in action.targets:
				avg += t.rotation
			if action.targets.size() > 0:
				avg /= action.targets.size()
			return avg + rotDegToRad(rotationOffset)
		_:
			return rotDegToRad(rotationOffset)

func rotDegToRad(rotRad):
	return Vector3(
		deg_to_rad(rotRad.x),
		deg_to_rad(rotRad.y),
		deg_to_rad(rotRad.z)
	)
