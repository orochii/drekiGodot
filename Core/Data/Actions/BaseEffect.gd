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
func apply(user:GameBattler, item:Resource, target:GameBattler, hit:bool=true):
	#var eff = calcEffect(user,item,target)
	# do stuff with effect i.e. change hp/mp/addstatus
	# any randomness occurs here, not on calcEffect
	return {"effective":false}

# This is for compatibility with AI
func calcEffect(user:GameBattler, item:Resource, target:GameBattler):
	# any calculation here must be deterministic
	return {}

# 1. Shouldn't affect healing effects
# 2. Shouldn't affect outside of battle
# 3. Yes
func applyDamagePositionEffect(user:GameBattler, item:Resource, target:GameBattler):
	var _damageAdjusted = 1.0
	if Global.Scene.inBattle(): return _damageAdjusted
	var _isRanged = false
	if item is UseableSkill:
		var uSkill = item as UseableSkill
		_isRanged = uSkill.flags.has(UseableSkill.ESkillFlags.RANGED)
	if user.getPosition() != 0 || _isRanged:
		_damageAdjusted -= 0.2
	if target.getPosition() != 0:
		_damageAdjusted -= 0.2
	return _damageAdjusted

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