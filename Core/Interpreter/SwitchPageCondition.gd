extends EventPageCondition
class_name SwitchPageCondition

@export var switchId : int
@export var value : bool

func check(ev:BaseEvent) -> bool:
	var v = Global.State.getSwitch(switchId)
	return v == value
