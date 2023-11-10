extends Control
class_name BattleActorSkillSelect

@export var actorCommand:BattleActorCommand
@export_group("Members")
@export var skillList:SkillList
@export var helpText:RichTextLabel
@export var statusWindow:BattleSkillStatusWindow

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
	_refreshHelp(true)

func close():
	visible = false
	skillList.active = false

func _process(delta):
	if !visible: return
	if actorCommand.battle.configMenu.visible: return
	_refreshHelp()
	if Input.is_action_just_pressed("action_cancel"):
		_goBack()

func _goBack():
	close()
	actorCommand.visible = true
	actorCommand.selectLast()

func _refreshHelp(force=false):
	var currItem = skillList.getCurrentItem()
	if currItem != lastItem || force:
		if currItem==null:
			helpText.text = ""
		else:
			helpText.text = currItem.getDesc()
		statusWindow.setup(currItem)
		lastItem = currItem

func _onSkillSelected(entry,skill):
	Global.Audio.playSFX("decision")
	var idx = skillList.getListIndex()
	battler().setLastIndex(&"skill", idx)
	battler().setWeaponIndex(idx)
	actorCommand.targetSelect.setup(skill)
