extends Control
class_name GameUI

@export var Message : GameMessage

func _init():
	Global.UI = self

func posToScreen(pos : Vector3) -> Vector2:
	var cam = get_viewport().get_camera_3d()
	return cam.unproject_position(pos)
