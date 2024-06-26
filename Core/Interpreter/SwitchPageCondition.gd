extends EventPageCondition
class_name SwitchPageCondition

@export var switchId : StringName
@export var value : bool

func check(ev) -> bool:
	var v = Global.State.getSwitch(switchId)
	return v == value
