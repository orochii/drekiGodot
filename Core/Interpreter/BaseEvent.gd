extends Node
class_name BaseEvent

func _ready():
	pass

func execute():
	Global.Ev.add(self)
	await _run()
	Global.Ev.remove(self)

func _run():
	var p = get_node("/root/Node3D/Player")
	await Global.UI.Message.showText(p, 2, "Longest speaker name everrrrrr", "hello world!")
	#await Global.Ev.wait(0.5)
	await Global.UI.Message.showText(p, 8, "", "second text? make it very loooooong for testing :O")
	await Global.UI.Message.showText(p, 4, "", "now left")
	await Global.UI.Message.showText(p, 6, "", "and now right")
