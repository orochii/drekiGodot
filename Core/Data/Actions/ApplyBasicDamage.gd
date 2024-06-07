extends BaseEffect
class_name ApplyBasicDamage

@export_group("Damage calculation")
@export var type : Global.EDamageType
@export var base : int
@export_range(0,5) var atkF:float = 0
@export_range(0,5) var strF:float = 0
@export_range(0,5) var vitF:float = 0
@export_range(0,5) var magF:float = 1
@export_range(0,5) var agiF:float = 0
@export_range(0,1) var pDefF:float = 0
@export_range(0,1) var mDefF:float = 1
@export var elements:Array[Global.Element]
@export_group("Chance and variance")
@export_range(0,1) var crit:float = 0.04
@export_range(0,1) var hit:float = 1
@export_range(0,1) var variance:float = 0
@export var ignoreHit:bool = false

var multipleTargets:bool = false

func execute(action:BattleAction):
	var effs = []
	multipleTargets = action.scope == Global.ETargetScope.ALL
	for t in action.targets:
		var _hit = ignoreHit || checkHit(1.0, action.battler.battler, t.battler)
		var eff = apply(action.battler.battler, action.action, t.battler, _hit)
		# Register effect to this turn
		effs.append(eff)
		# Display effect- eff(damage,elementCorrection,hit)
		t.damagePop(eff)
	# Store effects
	action.battler.turnEffects.append({&"type":&"damage",&"effects":effs})
	# Evaluate effects for limit
	evaluateEffects(effs)
	# Undo
	multipleTargets = false

# Data change ><
func apply(user:GameBattler, item:Resource, target:GameBattler, hit:bool=true):
	var eff = calcEffect(user,item,target)
	eff["user"] = user
	eff["target"] = target
	# Do hit
	eff["effective"] = true
	var r = randf()
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
		# Apply crit
		if critical:
			eff["damage"] = roundi(eff["damage"] * 1.5)
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

# any calculation here must be deterministic
func calcEffect(user:GameBattler, item:Resource, target:GameBattler):
	# Get attribute power (influence)
	var attr_power = (user.getStr() * strF) + (user.getMag() * magF)
	attr_power += (user.getVit() * vitF) + (user.getAgi() * agiF)
	# Invert for healing actions
	if base < 0: attr_power *= -1
	var power = base + attr_power
	# TODO: Skill power change features
	if (multipleTargets): power /= 2
	var damage = power
	# Subtract defense effect if damaging skill
	if base > 0:
		# Calculate defense
		var defense = (target.getVit() * pDefF) / 2
		defense += (target.getMag() * mDefF) / 2
		defense += power * (target.getPhyAbs() * 0.01 * pDefF)
		defense += power * (target.getMagAbs() * 0.01 * mDefF)
		# Apply defense change
		damage -= ceil(defense)
		if damage < 0: damage = 0
		damage *= applyDamagePositionEffect(user,item,target)
	# Physical skill multiplier
	if atkF > 0:
		var atkM = user.getAtk() * 0.01
		var atkV = (1 + atkM) * atkF
		damage = damage * atkV
	# TODO: Damage change features
	# Element correction
	var elementCorrection = target.getElementSetRate(elements)
	damage *= elementCorrection * 1.75 # Oh yes magical number!
	var _damage = adjustDamage(damage, getStatusLevel(user))
	# Return result
	return {
		"damage" : roundi(_damage),
		"elementCorrection" : elementCorrection,
		"type" : type
	}

func adjustDamage(v, level):
	var _plus = (level-1) * 0.5
	return v * (1 + _plus)