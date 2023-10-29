extends BaseEffect
class_name ApplyBasicDamage

@export var base : int

func execute(action:BattleAction):
	var targets = action.resolveTargets()
	for t in targets:
		print("Dealt %d damage on %s!" % [base,t.battler.getName()])
