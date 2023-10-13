extends Button
class_name PartyTargetEntry

@export var nameText:Label
@export var lpText:Label
@export var mpText:Label
@export var status1:NinePatchRect
@export var status2:NinePatchRect

var actor:GameActor

func setup(id:StringName):
	actor = Global.State.getActor(id)
	nameText.text = actor.name
	lpText.text = "%d" % actor.currHP
	mpText.text = "%d" % actor.currMP
	status1.texture = null
	status2.texture = null
