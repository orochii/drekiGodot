extends ActionScriptCondition
class_name ActionScriptCondition_Turn

@export var turnStart : int
@export var turnInterval : int

func evaluate(user:GameBattler, battle:BattleManager):
	var b = battle.findBattler(user)
	var currTurn = b.turn
	if currTurn < turnStart: return false
	var t = currTurn - turnStart
	return (t % turnInterval == 0)
