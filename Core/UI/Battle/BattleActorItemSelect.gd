extends Control
class_name BattleActorItemSelect

@export var actorCommand:BattleActorCommand
@export_group("Members")
#@export var itemList:ItemList
@export var helpText:RichTextLabel
#@export var statusWindow:BattleSkillStatusWindow

var lastItem:UseableItem

func _ready():
	visible = false
	#itemList.inBattle = true
	#itemList.onItemSelected = _onItemSelected

func battler():
	return actorCommand.currentBattler

func open():
	actorCommand.visible = false
	visible = true
	#statusWindow.setBattler(battler())
	#itemList.setup()
	#itemList.active = true
	var idx = battler().getLastIndex(&"skill")
	if(idx==null): idx = 0
	#itemList.setListIndex(idx)

func close():
	visible = false
	#itemList.active = false

func _process(delta):
	if !visible: return
	_refreshHelp()
	# TODO: Category change, equip left/right
	if Input.is_action_just_pressed("action_cancel"):
		_goBack()

func _goBack():
	close()
	actorCommand.visible = true
	actorCommand.selectLast()

func _refreshHelp():
	var currItem = null #itemList.getCurrentItem()
	if currItem != lastItem:
		if currItem==null:
			helpText.text = ""
		else:
			helpText.text = currItem.description
		#statusWindow.setup(currItem)
		lastItem = currItem

func _onItemSelected(entry,item):
	Global.Audio.playSFX("decision")
	#battler().setLastIndex(&"item", itemList.getListIndex())
	#actorCommand.targetSelect.setup(item)
