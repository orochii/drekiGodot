extends BaseEffect
class_name CameraZoomTo

@export var newZoom:float
@export var duration:float = 1.0
@export var waitUntilFinished:bool = true

func execute(action:BattleAction):
	var battle:BattleManager = action.battler.battle
	battle.camera.zoomTo(newZoom,duration)
	if waitUntilFinished: 
		await battle.get_tree().create_timer(duration).timeout
