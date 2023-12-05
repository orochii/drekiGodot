extends EventPageCondition
class_name LocalVarPageCondition

@export var variableName:StringName
@export var value:bool

func check(ev:BaseEvent) -> bool:
	var p = ev.get_parent()
	if p is NPC:
		return p.getLocalVar(variableName) == value
	if p is Trigger:
		return p.getLocalVar(variableName) == value
	return false
