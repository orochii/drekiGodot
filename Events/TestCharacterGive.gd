extends BaseEvent

@export var giveActor:Array[Actor]

func _run():
	var p = getPlayer()
	for actor in giveActor:
		Global.State.party.addMember(actor)
