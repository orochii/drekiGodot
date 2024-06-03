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
func apply(user:GameBattler, target:GameBattler, hit:bool=true):
	#var eff = calcEffect(user,target)
	# do stuff with effect i.e. change hp/mp/addstatus
	# any randomness occurs here, not on calcEffect
	return {"effective":false}

# This is for compatibility with AI
func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	return {}

func checkHit(hitBase:float, user:GameBattler, target:GameBattler):
	var h = hitBase
	# Apply deviation from user's features
	h = h * user.getHitRate()
	# Apply deviation due to target's features
	h = h - target.getEvasion()
	# Flying = 90% unless user has air juggling
	if target.isFlying() && !user.hasAirJuggling(): 
		h = h * 0.9
	# Do check
	var r = randf()
	return r < h

func getStatusLevel(user:GameBattler):
	return user.getResourceStatusLevel(self)