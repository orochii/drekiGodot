extends BaseEffect
class_name EscapeEffect

func execute(action:BattleAction):
	
	var targets = action.resolveTargets()
	for target in targets:
		target.escape()

func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	return {"excape":true}
