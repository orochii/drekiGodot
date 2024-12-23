extends Node
class_name CharacterEquipScreen

@export var charStats:CharacterStats
@export var charAdds:CharacterStatChanges
@export var description:RichTextLabel
@export var equipList:EquipList
@export var itemList:EquipItemList
@export var listSpawner:PartyListSpawner
@export var cursor:AnimatedSprite2D
var currIdx:int = 0
var actor:GameActor

func showTask(payload):
	if(payload != null):
		currIdx = payload[0]
		if(listSpawner != null): listSpawner.reposition(currIdx)
	var members = Global.State.party.getMembers()
	actor = Global.State.getActor(members[currIdx])
	description.text = ""
	charStats.setup(actor)
	equipList.setActor(actor)
	charAdds.setActor(actor)
func setFocus():
	equipList.focus()
func hideTask():
	if(actor==null): return
	actor.setCurrentWeapon(-1)
func reset():
	cursor.visible = false

var currFocus
var currItem:BaseItem = null

func _ready():
	cursor.visible = false
	cursor.play("default")

func _process(delta):
	if(get_parent().visible==false): return
	if Global.UI.Config.visible: return
	updateCurrItem()
	if(get_parent().active==false): return
	if(moveLeft()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(1,[currIdx])
		return
	if(moveRight()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(3,[currIdx])
		return
	if(cycleLeft()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size - 1) % size
		get_parent().get_parent().setScreen(2,[newIdx])
		return
	if(cycleRight()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size + 1) % size
		get_parent().get_parent().setScreen(2,[newIdx])
		return

func cycleLeft():
	return Input.is_action_just_pressed("cycle_left")
func cycleRight():
	return Input.is_action_just_pressed("cycle_right")

func updateCurrItem():
	var focused = get_viewport().gui_get_focus_owner()
	if (focused is EquipLine)||(focused is EquipEntry):
		cursor.visible = true
		if (focused is EquipLine):
			cursor.global_position = focused.global_position + Vector2(10,8)
		else:
			cursor.global_position = focused.global_position + Vector2(2,8)
	if focused != currFocus:
		currFocus = focused
		if currFocus is EquipLine:
			var i = currFocus as EquipLine
			currItem = i.item
			actor.setCurrentWeapon(i.weaponIdx)
			charStats.refresh()
			refreshItem()
			return
		elif currFocus is EquipEntry:
			var i = currFocus as EquipEntry
			currItem = i.data
			refreshItem()
			refreshAdds()
			return

func refreshItem():
	if currItem==null:
		description.text = ""
	else:
		description.text = TextUtils.parseText(currItem.getDesc())

func refreshAdds():
	charAdds.refreshAdds(currItem, itemList.idx)

func moveLeft():
	return false #Input.is_action_just_pressed("cycle_left")
func moveRight():
	return Input.is_action_just_pressed("action_extra")

func onSlotSelected(idx:int):
	Global.Audio.playSFX("decision")
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
	charAdds.visible = false

func equip(data):
	actor.equip(itemList.idx,data)
	charStats.setup(actor)
	equipList.setActor(actor)
	onListClose()
