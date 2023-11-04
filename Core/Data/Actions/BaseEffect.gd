extends Resource
class_name BaseEffect

# In-battle action execution
func execute(action:BattleAction):
	# action.action
	# action.battler
	# action.repeatIdx
	# action.totalRepeats
	# actions can actually never call apply if not necessary
	#var targets = action.resolveTargets()
	#for target in targets:
	#	apply(action.battler.battler, target)
	pass

# Data change
func apply(user:GameBattler, target:GameBattler):
	#var eff = calcEffect(user,target)
	# do stuff with effect i.e. change hp/mp/addstatus
	# any randomness occurs here, not on calcEffect
	pass

func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	return {}
