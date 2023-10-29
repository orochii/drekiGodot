extends Resource
class_name BaseEffect

func execute(action:BattleAction):
	# action.action
	# action.battler
	# action.repeatIdx
	# action.remainingTimes
	print("Someone is active! " + action.battler.getName())
	pass

# Planned actions
#	ApplyBasicDamage: hp/mp, amount, calc, etc
#	ApplyPercentDamage: hp/mp, amount
#	Scan: target
#	AddStatus: target, status
#	DisplayAnimation: target, animation
#	PlaySound: sfx
#	RunEvent: evt
#	
