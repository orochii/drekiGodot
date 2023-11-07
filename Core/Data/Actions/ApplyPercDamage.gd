extends BaseEffect
class_name ApplyPercDamage

@export_group("Damage calculation")
@export_enum("Current","Max") var base: int = 0
@export var type : Global.EDamageType
@export_enum("User","Target") var referenceBattler: int = 1
@export var percent : float
@export_group("Chance and variance")
@export_range(0,1) var crit:float = 0
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

func calcEffect(user:GameBattler, target:GameBattler):
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
	if base==1: value = ref.getMaxHP()
	# Calculate damage
	var damage = value * percent
	# Return result
	return {
		"damage" : roundi(damage),
		"type" : type
	}
