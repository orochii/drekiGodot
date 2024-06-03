extends BaseEffect
class_name RepeatIfDeadEffect

func execute(action:BattleAction):
	var anydead = false
	for target in action.targets:
		if target.battler.isDead():
			anydead = true
	if anydead:
		action.totalRepeats = action.totalRepeats + 1
