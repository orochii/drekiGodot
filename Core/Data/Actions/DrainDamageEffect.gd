extends BaseEffect
class_name DrainDamageEffect

@export_group("Drain type")
@export var type : Global.EDamageType
@export_range(0.0,1.0) var percent : float = 1
@export_enum("Total","Last Damage") var affectedDamage:int
@export var targetScope : Global.ETargetScope

var cachedDamage:int = 0
var targetSize:int = 1

func execute(action:BattleAction):
	# Get damage to be 
	cachePriorDamage(action.battler)
	#
	var innerAction = BattleAction.new()
	innerAction.battler = action.battler
	innerAction.action = action.action
	innerAction.kind = Global.ETargetKind.USER
	innerAction.scope = targetScope
	innerAction.targetIdx = 0
	var targets = innerAction.resolveTargets()
	targetSize = targets.size()
	for t in targets:
		var eff = apply(action.battler.battler, t.battler)
		# Display effect- eff(damage,elementCorrection,hit)
		t.damagePop(eff)

func apply(user:GameBattler, target:GameBattler, hit:bool=true):
	var eff = calcEffect(user,target)
	eff["target"] = target
	# Do hit
	eff["effective"] = true
	eff["hit"] = true
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

func calcEffect(user:GameBattler, target:GameBattler):
	# Get damage value
	var damage = cachedDamage * percent / targetSize
	# Return result
	return {
		"damage" : roundi(-damage),
		"elementCorrection" : 1.0,
		"type" : type
	}

func cachePriorDamage(user:Battler):
	cachedDamage = 0
	for i in range(user.turnEffects.size()-1, -1, -1):
		var eff = user.turnEffects[i]
		if eff[&"type"]==&"damage":
			for e in eff[&"effects"]:
				var _dmg = e["damage"]
				var _oldval = e["oldval"]
				if _dmg > _oldval: _dmg = _oldval
				cachedDamage += _dmg
			if affectedDamage==1: return
