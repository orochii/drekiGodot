extends Resource
class_name BaseEffect

# In-battle action execution
func execute(action:BattleAction):
	# action.action
	# action.battler
	# action.repeatIdx
	# action.totalRepeats
	print("%s executes effect." % action.battler.getName())
	# actions can actually never call apply if not necessary
	var targets = action.resolveTargets()
	for target in targets:
		apply(action.battler.battler, target)

# Data change
func apply(user:GameBattler, target:GameBattler):
	var eff = calcEffect(user,target)
	# do stuff with effect i.e. change hp/mp/addstatus
	# any randomness occurs here, not on calcEffect
	print("%s was targetted by this action." % [target.getName()])

func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	return {}
