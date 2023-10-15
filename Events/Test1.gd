extends BaseEvent

func _run():
	var p = get_node("/root/Node3D/Player")
	await Global.UI.Message.showText(p, 2, "Longest speaker name everrrrrr", "hello world!")
	#await Global.Ev.wait(0.5)
	await Global.UI.Message.showText(p, 8, "", "second text? make it very loooooong for testing :O")
	await Global.UI.Message.showText(p, 4, "", "now left")
	await Global.UI.Message.showText(p, 6, "", "and now right")
	Global.State.setSwitch(0,true)
	Global.State.party.gainItem("Drench", 3)
	Global.State.party.gainItem("Great Drench", 1)
	Global.State.party.gainItem("Short Bow", 1)
	Global.State.party.gainItem("Leather Gloves", 1)
