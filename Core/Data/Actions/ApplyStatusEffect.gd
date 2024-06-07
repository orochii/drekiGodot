extends BaseEffect
class_name ApplyStatusEffect

@export var status:Status
@export_enum("Add","Remove") var operation:int = 0
@export var forceAdd:bool = false
@export var hitChance:float = 1.0
@export var ignoreHit:bool = false
@export var considerLastHit:bool = false

# In-battle action execution
func execute(action:BattleAction):
	var effs = []
	for t in action.targets:
		var _prevHit = cachePriorHit(action.battler, t)
		var _hit = _prevHit && (ignoreHit || checkHit(hitChance, action.battler.battler, t.battler))
		var eff = apply(action.battler.battler, action.action, t.battler, _hit)
		effs.append(eff)
	# Store effects
	action.battler.turnEffects.append({&"type":&"status",&"effects":effs})
	# Evaluate effects for limit
	evaluateEffects(effs)

# Data change
func apply(user:GameBattler, item:Resource, target:GameBattler, hit:bool=true):
	var eff = calcEffect(user,item,target)
	eff["effective"] = false
	eff["user"] = user
	eff["target"] = target
	eff["hit"] = hit
	if hit:
		if eff.has("statusAdd"):
			for s in eff["statusAdd"]:
				eff["effective"] = target.addStatus(s,forceAdd) || eff["effective"]
		elif eff.has("statusRemove"):
			for s in eff["statusRemove"]:
				eff["effective"] = target.removeStatus(s) || eff["effective"]
	return eff

func calcEffect(user:GameBattler, item:Resource, target:GameBattler):
	# any calculation here must be deterministic
	match operation:
		0: # Add
			return {"statusAdd":[status]}
		1: # Remove
			return {"statusRemove":[status]}

func cachePriorHit(user:Battler, target:Battler):
	if considerLastHit==false: return true
	#
	for i in range(user.turnEffects.size()-1, -1, -1):
		var eff = user.turnEffects[i]
		for e in eff[&"effects"]:
			if e["target"] == target:
				return e["hit"]
