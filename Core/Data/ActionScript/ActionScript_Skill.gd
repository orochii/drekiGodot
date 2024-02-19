extends ActionScript
class_name ActionScript_Skill

@export var actions : Array[UseableSkill]

#action(s)
func makeDecision(battler:Battler) -> BattleAction:
	var action:BattleAction = BattleAction.new()
	action.battler = battler
	if actions.size() != 0:
		var r = randi_range(0, actions.size()-1)
		action.action = actions[r]
	else:
		action.action = Global.Db.defaultAttackSkills[0]
	action.kind = action.action.targetKind
	action.scope = action.action.targetScope
	action.selectRandomTarget()
	return action
