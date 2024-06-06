extends Button
class_name GenericItemEntry

@export var itemIcon:NinePatchRect
@export var itemLabel:Label

var enabled:bool = true

func setup(_text,_icon):
	itemIcon.texture = _icon
	itemLabel.text = _text

func setEnabled(v:bool):
	enabled = v
	if v: 
		modulate = Global.Db.systemColors[&"enabled"]
	else: 
		modulate = Global.Db.systemColors[&"disabled"]