extends Node

var currIdx:int = 0

func showTask(payload):
	if(payload != null):
		currIdx = payload[0]
	var members = Global.State.party.members
	var actor = Global.State.getActor(members[currIdx])
	#charStats.setup(actor)
func setFocus():
	pass
func hideTask():
	pass

func _process(delta):
	if(get_parent().visible==false): return
	if(get_parent().active==false): return
	if(moveLeft()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(2,[currIdx])
	if(moveRight()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(1,[currIdx])

func moveLeft():
	return false #Input.is_action_just_pressed("cycle_left")
func moveRight():
	return Input.is_action_just_pressed("action_extra")
