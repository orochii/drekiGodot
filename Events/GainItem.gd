extends BaseEvent

@export var item:BaseItem
@export var amount:int
@export var localVar:StringName = &""
@export var switchId:StringName = &""

func _run():
	if item==null:
		Global.State.party.gainGold(amount)
	else:
		Global.State.party.gainItem(item.getId(), amount)
		Global.UI.createItemPopup(item,amount,global_position)
	# Set state and whatnot.
	if switchId != &"":
		Global.State.setSwitch(switchId,true)
	if localVar != &"":
		get_parent().setLocalVar(localVar, true)
	get_parent().refreshPage()
