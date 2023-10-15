extends Control
class_name StatAddPair

@export var number:Label
@export var sign:Label
@export var format:String = "%d"

func setAdd(stat,style):
	number.text = format % stat
	number.label_settings = style
	sign.label_settings = style
