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
var toFocus = null

func showTask():
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
	if currMemberIdx < 0:
		get_parent().active = true
		memberSubmenu.visible = false
	else:
		showSubmenu(currMemberIdx,false)

func hideTask():
	pass

func _process(delta):
	if get_parent().visible==false: return
	if (memberSubmenu.visible==false): return
	if Input.is_action_just_pressed("action_cancel"):
		hideSubmenu()

func showSubmenu(i:int,reposition:bool=true):
	currMemberIdx = i
	get_parent().active = false
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

func _on_status_pressed():
	print (currMemberIdx)
	lastIdx = 0
	parentMenu.setScreen(1)

func _on_equip_pressed():
	print (currMemberIdx)
	lastIdx = 1
	parentMenu.setScreen(2)

func _on_actions_pressed():
	print (currMemberIdx)
	lastIdx = 2
	parentMenu.setScreen(3)
