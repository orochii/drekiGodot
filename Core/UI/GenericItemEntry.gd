extends Button
class_name GenericItemEntry

@export var itemIcon:NinePatchRect
@export var itemLabel:Label

func setup(_text,_icon):
	itemIcon.texture = _icon
	itemLabel.text = _text
