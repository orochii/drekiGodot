extends Control
class_name ActionNameWindow

@export var actionType:Label
@export var actionName:Label
@export var animation:AnimationPlayer

func pop(_type:String,_name:String):
	actionType.text = _type
	actionName.text = _name
	visible = true
	animation.stop()
	animation.play(&"display")

func _ready():
	visible=false
