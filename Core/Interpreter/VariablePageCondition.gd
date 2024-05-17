extends EventPageCondition
class_name VariablePageCondition

enum ECompareOper { EQUAL, NOT_EQUAL, 
					LESS_THAN, GREATER_THAN, 
					LESS_OR_EQUAL, GREATER_OR_EQUAL }

@export var variableId : StringName
@export var compare : ECompareOper
@export var value : int

func check(ev:BaseEvent) -> bool:
	var v = Global.State.getVariable(variableId)
	match compare:
		ECompareOper.NOT_EQUAL:
			return v != value
		ECompareOper.LESS_THAN:
			return v < value
		ECompareOper.GREATER_THAN:
			return v > value
		ECompareOper.LESS_OR_EQUAL:
			return v <= value
		ECompareOper.GREATER_OR_EQUAL:
			return v >= value
		_:
			return v == value
