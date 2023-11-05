extends Resource
class_name BaseEffect

# In-battle action execution
func execute(action:BattleAction):
	# action.action
	# action.battler
	# action.repeatIdx
	# action.totalRepeats
	# actions can actually never call apply if not necessary
	#for target in action.targets:
	#	apply(action.battler.battler, target)
	pass

# Data change - This adds compatibility with effects outside of battle
func apply(user:GameBattler, target:GameBattler):
	#var eff = calcEffect(user,target)
	# do stuff with effect i.e. change hp/mp/addstatus
	# any randomness occurs here, not on calcEffect
	pass

# This is for compatibility with AI
func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	return {}
