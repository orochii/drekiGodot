extends Node
class_name CharacterEquipScreen

@export var charStats:CharacterStats
# @export var charAdds:CharacterStatChanges
@export var description:RichTextLabel
@export var equipList:EquipList
@export var itemList:EquipItemList
var currIdx:int = 0
var actor:GameActor

func showTask(payload):
	if(payload != null):
		currIdx = payload[0]
	var members = Global.State.party.members
	actor = Global.State.getActor(members[currIdx])
	charStats.setup(actor)
	equipList.setActor(actor)
	#itemList.refreshList()
func setFocus():
	equipList.focus()
func hideTask():
	pass

var currFocus
var currItem:BaseItem = null

func _process(delta):
	if(get_parent().visible==false): return
	updateCurrItem()
	if(get_parent().active==false): return
	if(moveLeft()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(1,[currIdx])
	if(moveRight()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(3,[currIdx])

func updateCurrItem():
	var focused = get_viewport().gui_get_focus_owner()
	if focused != currFocus:
		currFocus = focused
		if currFocus is EquipLine:
			var i = currFocus as EquipLine
			currItem = i.item
			refreshItem()
			return
		if currFocus is EquipEntry:
			var i = currFocus as EquipEntry
			currItem = i.data
			refreshItem()
			refreshAdds()
			return

func refreshItem():
	if currItem==null:
		description.text = ""
	else:
		description.text = currItem.description

func refreshAdds():
	pass

func moveLeft():
	return false #Input.is_action_just_pressed("cycle_left")
func moveRight():
	return Input.is_action_just_pressed("action_extra")

func onSlotSelected(idx:int):
	Global.Audio.resetLastFocused()
	get_parent().active = false
	equipList.visible = false
	itemList.refreshList(actor,idx)
	itemList.showMenu()

func onListClose():
	equipList.visible = true
	itemList.visible = false
	get_parent().active = true
	equipList.focus(itemList.idx)

func equip(data):
	actor.equip(itemList.idx,data)
	charStats.setup(actor)
	equipList.setActor(actor)
	onListClose()
