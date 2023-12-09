extends Button

@export var label:Label

var action:Callable
var index:int

func setup(i:int,text:String):
	label.text = text
	index = i

func _on_pressed():
	action.call(index)
