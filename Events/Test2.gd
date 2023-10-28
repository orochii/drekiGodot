extends BaseEvent

func _run():
	var p = get_node("/root/Node3D/Player")
	await Global.UI.Message.showText(p, 8, "", "Hi there! Uh yeah, again.")
	Global.State.setSwitch(0,false)
	Global.State.party.gainItem("Weapon/Sword", 1)
	Global.State.party.gainItem("Great Drench", 1)
	Global.State.party.gainItem("Antidote", 1)
	Global.State.party.gainItem("Bandage", 1)
	Global.State.party.gainItem("Drench", 1)
	Global.State.party.gainItem("Eldritch Watch", 1)
	Global.State.party.gainItem("Elixir", 1)
	Global.State.party.gainItem("Ether", 1)
	Global.State.party.gainItem("Lifesaver S", 1)
	Global.State.party.gainItem("Lifesaver M", 1)
	Global.State.party.gainItem("Lifesaver L", 1)
	Global.State.party.gainItem("Lunar Teardrop", 1)
	Global.State.party.gainItem("Mid Tonic", 1)
	Global.State.party.gainItem("Panacea", 1)
	Global.State.party.gainItem("Phoenix Feather", 1)
	Global.State.party.gainItem("Phoenix Tail", 1)
	Global.State.party.gainItem("Root", 1)
	Global.State.party.gainItem("Stem", 1)
	Global.State.party.gainItem("Thaw", 1)
	Global.State.party.gainItem("Tonic", 1)