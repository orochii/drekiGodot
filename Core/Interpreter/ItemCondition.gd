extends EventPageCondition
class_name ItemCondition

@export var requiredItem:BaseItem
@export var condition:bool

func check(ev) -> bool:
	if requiredItem != null:
		return Global.State.party.hasItem(requiredItem.getId()) == condition
	return true
