extends BaseEffect
class_name AfterimageEffect

@export var enabled:bool
@export var interval:float

func execute(action:BattleAction):
	action.battler.afterimageEnabled = enabled
	action.battler.afterimageInterval = interval
