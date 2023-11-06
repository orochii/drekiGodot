extends Resource
class_name ActionScript

#priority
@export_range(1,10) var priority : int = 5
#condition
@export var conditions : Array[ActionScriptCondition]

#action(s)
func makeDecision(battler:Battler) -> BattleAction:
	var action:BattleAction = BattleAction.new()
	action.battler = battler
	action.action = Global.Db.defaultAttackSkills[0]
	action.kind = action.action.targetKind
	action.scope = action.action.targetScope
	action.selectRandomTarget()
	return action
