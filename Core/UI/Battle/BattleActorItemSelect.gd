extends Control
class_name BattleActorItemSelect

@export var actorCommand:BattleActorCommand
@export_group("Members")
@export var itemList:ItemsList
@export var helpText:RichTextLabel
@export var statusWindow:BattleItemStatus

var lastItem:BaseItem

func _ready():
	visible = false
	itemList.inBattle = true
	itemList.onItemSelected = _onItemSelected

func battler():
	return actorCommand.currentBattler

func open():
	actorCommand.visible = false
	visible = true
	statusWindow.setup(battler())
	itemList.setup()
	itemList.active = true
	var idx = battler().getLastIndex(&"item")
	if(idx==null): idx = 0
	itemList.setListIndex(idx)
	_refreshHelp(true)

func close():
	visible = false
	itemList.active = false

func _process(delta):
	if !visible: return
	_refreshHelp()
	# TODO: Category change, equip left/right
	if Input.is_action_just_pressed("cycle_left"):
		if _equipTo(0):
			Global.Audio.playSFX("equip")
			itemList.refresh()
			statusWindow.setup(battler())
		else:
			Global.Audio.playSFX("buzzer")
		return
	if Input.is_action_just_pressed("cycle_right"):
		if _equipTo(1):
			Global.Audio.playSFX("equip")
			itemList.refresh()
			statusWindow.setup(battler())
		else:
			Global.Audio.playSFX("buzzer")
		return
	if Input.is_action_just_pressed("action_extra"):
		Global.Audio.playSFX("cursor")
		_changeCategory()
		return
	if Input.is_action_just_pressed("action_cancel"):
		_goBack()

func _equipTo(slot:int):
	if battler().battler is GameActor:
		var item = itemList.getCurrentItem()
		if item is EquipItem:
			var equip = item as EquipItem
			var actor = battler().battler as GameActor
			return actor.equip(slot, equip)
	return false

func _changeCategory():
	itemList.switchCatForward()

func _goBack():
	close()
	actorCommand.visible = true
	actorCommand.selectLast()

func _refreshHelp(force=false):
	var currItem = itemList.getCurrentItem()
	if currItem != lastItem || force:
		if currItem==null:
			helpText.text = ""
		else:
			helpText.text = currItem.description
		#statusWindow.setup(currItem)
		lastItem = currItem

func _onItemSelected(obj, item, entry):
	Global.Audio.playSFX("decision")
	battler().setLastIndex(&"item", itemList.getListIndex())
	actorCommand.targetSelect.setup(item)
