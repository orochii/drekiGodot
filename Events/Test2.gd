extends BaseEvent

func _run():
	var p = get_node("/root/Node3D/Player")
	await Global.UI.Message.showText(p, 8, "", "Hi there! Uh yeah, again.")
	Global.State.setSwitch(0,false)
	Global.State.party.gainItem("Sword", 1)
	Global.State.party.gainItem("GreatDrench", 1)
