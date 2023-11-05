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

var multipleTargets:bool = false

func execute(action:BattleAction):
	multipleTargets = action.scope == Global.ETargetScope.ALL
	for t in action.targets:
		var eff = apply(action.battler.battler, t.battler)
		# Display effect- eff(damage,elementCorrection,hit)
		t.damagePop(eff)

# Data change ><
func apply(user:GameBattler, target:GameBattler):
	var eff = calcEffect(user,target)
	# Do hit
	var r = randf()
	eff["hit"] = r < hit
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
				target.changeHP(-eff["damage"])
			Global.EDamageType.MP:
				target.changeMP(-eff["damage"])
	return eff

# any calculation here must be deterministic
func calcEffect(user:GameBattler, target:GameBattler):
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
		defense += power * (target.getPhyAbs() * pDefF * 0.01)
		defense += power * (target.getMagAbs() * mDefF * 0.01)
		# Apply defense change
		damage -= ceil(defense)
		if damage < 0: damage = 0
	# Physical skill multiplier
	if atkF > 0:
		var atkM = user.getAtk() * 0.01
		var atkV = (1 + atkM) * atkF
		damage = damage * atkV
	# TODO: Damage change features
	# Element correction
	var elementCorrection = target.getElementSetRate(elements)
	damage *= elementCorrection
	# Return result
	return {
		"damage" : roundi(damage),
		"elementCorrection" : elementCorrection,
		"type" : type
	}
