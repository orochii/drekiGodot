extends Node
class_name PartyListSpawner

@export var parentMenu : PartyMenu
@export var partyMemberTemplate : PackedScene
@export var container : Control
@export var memberSubmenu : Control
@export var memberSubmenuButtons : Array[Button]

var spawnedMembers : Array
var currMemberIdx:int = -1
var lastIdx:int = -1
var backupMemberIdx:int = -1
var toFocus = null
var active = false

func showTask(payload):
	if spawnedMembers != null:
		for c in spawnedMembers:
			c.queue_free()
	spawnedMembers.clear()
	var members : Array = Global.State.party.members
	for i in range(members.size()):
		var m = members[i]
		var actor = Global.State.getActor(m)
		var inst = partyMemberTemplate.instantiate()
		container.add_child(inst)
		inst.setActor(i,actor)
		inst.parentMenu = self
		spawnedMembers.append(inst)
	#container.repositionChildren()
	if currMemberIdx < 0:
		get_parent().active = true
		memberSubmenu.visible = false
		if payload != null:
			if payload.size() > 0: toFocus = payload[0]
			if payload.size() > 1: currMemberIdx = payload[1]
	else:
		showSubmenu(currMemberIdx,false)

func hideTask():
	pass
func reset():
	currMemberIdx = -1
	lastIdx = -1
	backupMemberIdx = -1
	active = false

func _process(delta):
	if(active==false): return
	if get_parent().visible==false: return
	if get_parent().active==true:
		var focused = get_viewport().gui_get_focus_owner()
		if (focused==null || !focused.is_visible_in_tree()):
			if(backupMemberIdx != -1):
				spawnedMembers[backupMemberIdx].grab_focus()
		return
	
	if (memberSubmenu.visible==false): return
	if Input.is_action_just_pressed("action_cancel"):
		Global.Audio.playSFX("cancel")
		hideSubmenu()

func showSubmenu(i:int,reposition:bool=true):
	if(active==false): return
	get_parent().active = false
	currMemberIdx = i
	backupMemberIdx = i
	var ref = spawnedMembers[i]
	if reposition:
		var pos = ref.global_position + Vector2(56,0)
		memberSubmenu.position = pos
	memberSubmenu.visible = true
	if lastIdx < 0: 
		toFocus = memberSubmenuButtons[0]
	else:
		toFocus = memberSubmenuButtons[lastIdx]
	ref.setActive(true)

func reposition(i:int):
	currMemberIdx = i
	var ref = spawnedMembers[i]
	var pos = ref.global_position + Vector2(56,0)
	memberSubmenu.position = pos

func hideSubmenu():
	get_parent().active = true
	memberSubmenu.visible = false
	spawnedMembers[currMemberIdx].grab_focus()
	spawnedMembers[currMemberIdx].setActive(false)
	currMemberIdx = -1
	lastIdx = -1

func setFocus():
	if(toFocus != null):
		toFocus.grab_focus()
		toFocus = null
	active = true

func _on_status_pressed():
	Global.Audio.playSFX("decision")
	lastIdx = 0
	parentMenu.setScreen(1,[currMemberIdx])

func _on_equip_pressed():
	Global.Audio.playSFX("decision")
	lastIdx = 1
	parentMenu.setScreen(2,[currMemberIdx])

func _on_actions_pressed():
	Global.Audio.playSFX("decision")
	lastIdx = 2
	parentMenu.setScreen(3,[currMemberIdx])
