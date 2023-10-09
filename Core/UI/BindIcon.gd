extends Sprite2D

@export var bindName : StringName = "action_ok"

func _ready():
	pass # Replace with function body.

func _process(delta):
	self.texture = Global.Db.iconLibrary.getActionIcon(bindName)
