extends ColorRect
class_name ExpChangeBar

@export var width:int = 94
@export var barOld:ColorRect
@export var barChange:ColorRect
@export_group("Colors")
@export var barColor:Color
@export var changeColor:Color
@export var upColor:Color

func setup(old:float,change:float):
	var curr = old + change
	if curr >= 1: # Up!
		barOld.visible = false
		barChange.visible = true
		barChange.position = barOld.position
		barChange.size.x = width
		barChange.color = upColor
	else:
		barOld.visible = true
		barOld.size.x = roundi(old * width)
		barChange.position.x = barOld.position.x + barOld.size.x
		barChange.size.x = roundi(change * width)
		barChange.color = changeColor
		barChange.visible = true
