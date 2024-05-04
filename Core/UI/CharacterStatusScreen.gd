extends Node

@export var charStats : CharacterStats
@export var listSpawner:PartyListSpawner

var currIdx = 0

# PAYLOAD: [partyIdx]
func showTask(payload):
	if(payload != null):
		currIdx = payload[0]
		if(listSpawner != null): listSpawner.reposition(currIdx)
	var members = Global.State.party.getMembers()
	var actor = Global.State.getActor(members[currIdx])
	charStats.setup(actor)
func setFocus():
	pass
func hideTask():
	pass
func reset():
	pass

func _process(delta):
	if(get_parent().visible==false): return
	if(get_parent().active==false): return
	if(moveLeft()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(3,[currIdx])
		return
	if(moveRight()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(2,[currIdx])
		return
	if(cycleLeft()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size - 1) % size
		get_parent().get_parent().setScreen(1,[newIdx])
		return
	if(cycleRight()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size + 1) % size
		get_parent().get_parent().setScreen(1,[newIdx])
		return

func cycleLeft():
	return Input.is_action_just_pressed("cycle_left")
func cycleRight():
	return Input.is_action_just_pressed("cycle_right")

func moveLeft():
	return false #Input.is_action_just_pressed("cycle_left")
func moveRight():
	return Input.is_action_just_pressed("action_extra")
