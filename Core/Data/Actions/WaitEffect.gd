extends BaseEffect
class_name WaitEffect

@export var waitTime:float = 1

func execute(action:BattleAction):
	await action.battler.get_tree().create_timer(waitTime).timeout
