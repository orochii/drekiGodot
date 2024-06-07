extends BaseEffect
class_name ApplyPercDamage

@export_group("Damage calculation")
@export_enum("Current","Max") var base: int = 0
@export var type : Global.EDamageType
@export_enum("User","Target") var referenceBattler: int = 1
@export var percent : float
@export_group("Chance and variance")
@export_range(0,1) var crit:float = 0
@export_range(0,1) var hitChance:float = 1
@export_range(0,1) var variance:float = 0
@export var ignoreHit:bool = false

var multipleTargets:bool = false

func execute(action:BattleAction):
	var effs = []
	multipleTargets = action.scope == Global.ETargetScope.ALL
	for t in action.targets:
		var _hit = ignoreHit || checkHit(hitChance, action.battler.battler, t.battler)
		var eff = apply(action.battler.battler, action.action, t.battler, _hit)
		# Register effect to this turn
		effs.append(eff)
		# Display effect- eff(damage,elementCorrection,hit)
		t.damagePop(eff)
	# Store effects
	action.battler.turnEffects.append({&"type":&"damage",&"effects":effs})
	# Evaluate effects for limit
	evaluateEffects(effs)

# Data change ><
func apply(user:GameBattler, item:Resource, target:GameBattler, hit:bool=true):
	var eff = calcEffect(user,item,target)
	# Do hit
	eff["effective"] = true
	eff["user"] = user
	eff["target"] = target
	eff["hit"] = hit
	if eff["hit"]:
		# Apply crit
		var rCrit = randf()
		var critical = crit > rCrit
		eff["critical"] = critical
		# Apply variance
		if variance > 0:
			var v = 1 - variance + (randf() * variance * 2)
			eff["damage"] = roundi(eff["damage"] * v)
		# Apply effect
		match type:
			Global.EDamageType.HP:
				eff["oldval"] = target.currHP
				target.changeHP(-eff["damage"])
				eff["effective"] = eff["oldval"] != target.currHP
			Global.EDamageType.MP:
				eff["oldval"] = target.currMP
				target.changeMP(-eff["damage"])
				eff["effective"] = eff["oldval"] != target.currMP
	return eff

func calcEffect(user:GameBattler, item:Resource, target:GameBattler):
	var ref = target
	var value = 0
	if(referenceBattler==0): ref = user
	match type:
		Global.EDamageType.HP:
			match base:
				0:
					value = ref.currHP
				1:
					value = ref.getMaxHP()
		Global.EDamageType.MP:
			match base:
				0:
					value = ref.currMP
				1:
					value = ref.getMaxMP()
	#if base==1: value = ref.getMaxHP()
	# Calculate damage
	var _adjustedPerc = adjustDamage(percent, getStatusLevel(user))
	var damage = value * _adjustedPerc
	# Return result
	return {
		"damage" : roundi(damage),
		"type" : type
	}

func adjustDamage(v, level):
	var _plus = (level-1) * 0.5
	return v * (1 + _plus)