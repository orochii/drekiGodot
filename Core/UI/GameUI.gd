extends Control
class_name GameUI

@export var Message : GameMessage
@export var Party : PartyMenu
@export var File : FileMenu
@export var Config : ConfigMenu
@export var compass:Node3D

var currLang = "en"

func _init():
	Global.UI = self

func _process(delta):
	Global.State.playTime += delta
	if compass != null:
		var cam = get_viewport().get_camera_3d()
		compass.global_rotation = cam.global_rotation

func busy():
	if Global.Scene.transferring: return true
	if (Message.busy()): return true
	return false

func posToScreen(pos : Vector3) -> Vector2:
	var cam = get_viewport().get_camera_3d()
	return cam.unproject_position(pos)

func screenSize() -> Vector2:
	return get_viewport().get_visible_rect().size
