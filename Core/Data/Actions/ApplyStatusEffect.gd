extends BaseEffect
class_name ApplyStatusEffect

@export var status:Status
@export_enum("Add","Remove") var operation:int = 0
@export var forceAdd:bool = false

# In-battle action execution
func execute(action:BattleAction):
	for target in action.targets:
		apply(action.battler.battler, target.battler)

# Data change
func apply(user:GameBattler, target:GameBattler):
	var eff = calcEffect(user,target)
	eff["effective"] = false
	if eff.has("statusAdd"):
		for s in eff["statusAdd"]:
			eff["effective"] = target.addStatus(s,forceAdd) || eff["effective"]
	elif eff.has("statusRemove"):
		for s in eff["statusRemove"]:
			eff["effective"] = target.removeStatus(s) || eff["effective"]

func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	match operation:
		0: # Add
			return {"statusAdd":[status]}
		1: # Remove
			return {"statusRemove":[status]}
