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
	if !Global.Scene.inBattle(): return _damageAdjusted
	var _isRanged = true
	if item is UseableSkill:
		var uSkill = item as UseableSkill
		_isRanged = uSkill.flags.has(UseableSkill.ESkillFlags.RANGED)
	#
	var userBattler = Global.Battle.findBattler(user)
	var targetBattler = Global.Battle.findBattler(target)
	if user != null && target != null:
		var userDeg = userBattler.rotation_degrees.y
		var targetDeg = targetBattler.rotation_degrees.y
		var deltaDeg = abs(targetDeg - userDeg)
		print("userDeg:%f targetDeg:%f delta:%f" % [userDeg, targetDeg, deltaDeg])
		if deltaDeg < 90.0:
			_damageAdjusted += 1.0
	#
	if !_isRanged: 
		match user.getPosition():
			0:
				_damageAdjusted += 0.2
			1:
				_damageAdjusted -= 0.2
	if target.getPosition() != 0:
		_damageAdjusted -= 0.3
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

func evaluateEffects(effs:Array):
	# Initialize total gain
	var _totalGain = 0.0
	var raise_rate = 1.0 / 256
	# Iter through effects
	for eff in effs:
		# If effect successfully hits
		if eff.has("target") && eff.has("hit") && eff.has("effective"):
			if eff["effective"] && eff["hit"]:
				# Damaging effects: no recovery, only enemies
				var targetsEnemy = eff["target"].isEnemy(eff["user"])
				var targetIsActor = eff["target"] is GameActor
				if targetsEnemy && eff.has("damage") && eff["damage"]>0:
					var _dmg = float(eff["damage"])
					var _ratio = _dmg / eff["user"].getMaxHP()
					var _perc = _dmg / eff["target"].getMaxHP()
					var _mult = 4 + _ratio + _perc
					if targetIsActor:
						_mult *= 2
						if eff.has("critical") && eff["critical"]:
							_mult *= 1.5
					else:
						_mult *= 3
					_totalGain = _mult * raise_rate
				# Bonus from status change
				if targetsEnemy:
					if eff.has("statusAdd"):
						_totalGain += 0.02
				if !targetsEnemy:
					if eff.has("statusRemove"):
						_totalGain += 0.02
	var lb = Global.Scene.battleInstance.limitBar
	lb.currentValue = clampf(lb.currentValue + _totalGain, 0.0, 1.0)
