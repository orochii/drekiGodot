extends Node
class_name CharacterActionsScreen

@export var charStats:CharacterStats
@export var slotsContainer:LearnSlotsContainer
@export var skillList:SkillList
@export var listSpawner:PartyListSpawner
@export var skillTargetWindow : SkillTarget

var currIdx:int = 0
var toFocus = null

func showTask(payload):
	if(payload != null):
		currIdx = payload[0]
		if(listSpawner != null): listSpawner.reposition(currIdx)
	var members = Global.State.party.getMembers()
	var actor = Global.State.getActor(members[currIdx])
	charStats.setup(actor)
	slotsContainer.setup(actor)
	skillList.setup(actor)
	skillList.onSkillSelected = _onSkillSelected
	toFocus = skillList.getFirst()
	skillList.visible = true
func setFocus():
	if(toFocus != null):
		toFocus.grab_focus()
	skillList.active = true
func hideTask():
	pass
func reset():
	skillList.active = false

func _process(delta):
	if(get_parent().visible==false): return
	if(get_parent().active==false): return
	if Global.UI.Config.visible: return
	if(skillTargetWindow.visible==true): return
	if(slotsContainer.active): return
	if(Input.is_action_just_pressed("action_menu")):
		setSkillList(false)
		Global.Audio.playSFX("decision")
		return
	if(moveLeft()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(2,[currIdx])
		return
	if(moveRight()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(1,[currIdx])
		return
	if(cycleLeft()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size - 1) % size
		get_parent().get_parent().setScreen(3,[newIdx])
		return
	if(cycleRight()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size + 1) % size
		get_parent().get_parent().setScreen(3,[newIdx])
		return

func cycleLeft():
	return Input.is_action_just_pressed("cycle_left")
func cycleRight():
	return Input.is_action_just_pressed("cycle_right")
func moveLeft():
	return false #Input.is_action_just_pressed("cycle_left")
func moveRight():
	return Input.is_action_just_pressed("action_extra")

func setSkillList(v:bool):
	if v==false:
		_oldListIdx = skillList.getListIndex()
		get_viewport().gui_release_focus()
	skillList.visible = v
	slotsContainer.active = !v
	get_parent().active = v
	if v == true:
		skillList.setListIndex(_oldListIdx)

var _oldListIdx = -1

func getActor():
	var members = Global.State.party.getMembers()
	return Global.State.getActor(members[currIdx])

func _onSkillSelected(entry,skill):
	Global.Audio.playSFX("decision")
	# open target list
	skillTargetWindow.open(getActor(), skill)
