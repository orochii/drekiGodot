extends Control
class_name BattleActorSkillSelect

@export var skillList:SkillList
@export var helpText:RichTextLabel
@export var statusWindow:BattleSkillStatusWindow
@export var actorCommand:BattleActorCommand

var lastItem:UseableSkill

func _ready():
	visible = false
	skillList.inBattle = true
	skillList.onSkillSelected = _onSkillSelected

func battler():
	return actorCommand.currentBattler

func open():
	actorCommand.visible = false
	visible = true
	statusWindow.setBattler(battler())
	skillList.setup(battler().battler)
	skillList.active = true
	var idx = battler().getLastIndex(&"skill")
	if(idx==null): idx = 0
	skillList.setListIndex(idx)

func _process(delta):
	if !visible: return
	_refreshHelp()
	if Input.is_action_just_pressed("action_cancel"):
		_goBack()

func _goBack():
	visible = false
	skillList.active = false
	actorCommand.visible = true
	actorCommand.selectLast()

func _onSkillSelected(entry,skill):
	Global.Audio.playSFX("decision")
	battler().setLastIndex(&"skill", skillList.getListIndex())

func _refreshHelp():
	var currItem = skillList.getCurrentItem()
	if currItem != lastItem:
		if currItem==null:
			helpText.text = ""
		else:
			helpText.text = currItem.description
		statusWindow.setup(currItem)
		lastItem = currItem
