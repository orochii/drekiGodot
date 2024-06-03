extends BaseEffect
class_name CameraLookToEffect

@export_enum("User", "Targets", "Absolute") var target: int
@export var referencePosition: Vector3 = Vector3(0.8,0,0)
@export var positionOffset:Vector3
@export var duration:float = 1.0
@export var waitUntilFinished:bool = true

func execute(action:BattleAction):
	var pos = _resolveTargetPosition(action)
	var battle:BattleManager = action.battler.battle
	battle.camera.lookTo(pos,duration)
	if waitUntilFinished: 
		await battle.get_tree().create_timer(duration).timeout

func _resolveTargetPosition(action:BattleAction):
	match target:
		0:
			var t = action.battler
			var pos = t.homePosition
			var size = t.getSize()
			var radius:float = size.x / 2
			var height:float = size.y
			var moveOffset = Vector3(radius,height,radius) * referencePosition
			return action.battler.position + positionOffset + moveOffset
		1:
			var avg = Vector3()
			for t in action.targets:
				avg += t.position
			if action.targets.size() > 0:
				avg /= action.targets.size()
			var radius = 0
			var height:float = 0
			for t in action.targets:
				var pos = t.homePosition
				var size = t.getSize()
				var dst = avg.distance_to(pos) + (size.x / 2)
				if radius < dst: radius = dst
				if height < size.y: height = size.y
			var moveOffset = Vector3(radius,height,radius) * referencePosition
			return avg + positionOffset + moveOffset
		_:
			return positionOffset
