extends BaseEffect
class_name EscapeEffect

func execute(action:BattleAction):
	for target in action.targets:
		target.escape()

func calcEffect(user:GameBattler, item:Resource, target:GameBattler):
	# any calculation here must be deterministic
	return {"escape":true}
