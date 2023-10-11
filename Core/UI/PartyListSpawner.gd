extends Node
class_name PartyListSpawner

@export var parentMenu : PartyMenu
@export var partyMemberTemplate : PackedScene
@export var container : Control
var spawnedMembers : Array

func runTask():
	if spawnedMembers != null:
		for c in spawnedMembers:
			c.queue_free()
	spawnedMembers.clear()
	var members : Array = Global.State.party.members
	for m in members:
		var actor = Global.State.getActor(m)
		var inst = partyMemberTemplate.instantiate()
		container.add_child(inst)
		inst.setActor(actor)
		inst.parentMenu = parentMenu
		spawnedMembers.append(inst)
