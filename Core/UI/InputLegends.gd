extends Node
class_name InputLegends

@export var leftTop : Label
@export var rightTop : Label
@export var extraObj : Control
@export var extraAction : Label
@export var helpObj : Control

func setTexts(left:String,right:String,extra:String,showHelp:bool):
	leftTop.text = left
	rightTop.text = right
	if extra == "":
		extraObj.visible = false
	else:
		extraObj.visible = true
		extraAction.text = extra
	helpObj.visible = showHelp
