extends Node
class_name BaseEvent

func _ready():
	pass

func execute():
	Global.Ev.add(self)
	await run()
	Global.Ev.remove(self)

func run():
	await Global.UI.Message.showText("hello world!")
	await Global.Ev.wait(2)
	await Global.UI.Message.showText("second text?")
