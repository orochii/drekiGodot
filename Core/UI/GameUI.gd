extends Control
class_name GameUI

@export var Message : GameMessage
@export var Party : PartyMenu

var currLang = "en"

func _init():
	Global.UI = self

func _process(delta):
	if Input.is_action_just_pressed("action_select"):
		if currLang == "en":
			currLang = "es"
		else:
			currLang = "en"
		TranslationServer.set_locale(currLang)

func busy():
	if Global.Scene.transferring: return true
	if (Message.busy()): return true
	return false

func posToScreen(pos : Vector3) -> Vector2:
	var cam = get_viewport().get_camera_3d()
	return cam.unproject_position(pos)

func screenSize() -> Vector2:
	return get_viewport().get_visible_rect().size
