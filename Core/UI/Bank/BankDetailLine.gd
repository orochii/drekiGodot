extends HBoxContainer

@export var detail:Label
@export var amount:Label
@export var colors:Array[LabelSettings]

func setup(key,value):
	detail.text = key
	if value >= 0:
		amount.text = "+%d"%value
		amount.label_settings = colors[0]
	else:
		amount.text = "%d"%value
		amount.label_settings = colors[1]
