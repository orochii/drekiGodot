extends Node

@export var buttons : Array[Button]
@export var cursor:AnimatedSprite2D

var toFocus = null

func showTask(payload):
	buttons[0].modulate = Global.UI.getEnabledColor(_isSaveAllowed())
	buttons[1].modulate = Global.UI.getEnabledColor(_isLoadAllowed())
	if payload != null:
		if payload.size() > 0:
			toFocus = buttons[payload[0]]
func setFocus():
	if(toFocus != null):
		toFocus.grab_focus()
		toFocus = null
func hideTask():
	cursor.visible = false
func reset():
	cursor.visible = false

func _ready():
	UIUtils.setVNeighbors(buttons)
	cursor.play("default")
func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if(focused is Button && buttons.has(focused)):
		positionCursor(focused)

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(2,8)
	else:
		cursor.visible = false

func _isSaveAllowed():
	return true
func _isLoadAllowed():
	return (Global.getSaveFileList().size() != 0)

func _on_save_pressed():
	if !_isSaveAllowed(): #Global.getSaveFileList().size() != 0:
		Global.Audio.playSFX("cancel")
		return
	Global.Audio.playSFX("decision")
	Global.UI.File.open(0,true)
	Global.UI.Party.close()
func _on_load_pressed():
	if !_isLoadAllowed():
		Global.Audio.playSFX("cancel")
		return
	Global.Audio.playSFX("decision")
	Global.UI.File.open(1,true)
	Global.UI.Party.close()
func _on_config_pressed():
	Global.Audio.playSFX("decision")
	Global.UI.Config.open(true)
	Global.UI.Party.close()
func _on_to_title_pressed():
	Global.Audio.playSFX("decision")
	Global.Scene.toTitle()
func _on_quit_pressed():
	Global.Audio.playSFX("decision")
	get_parent().active = false
	Global.Scene.quit()
func _on_back_pressed():
	Global.Audio.playSFX("decision")
	get_parent().returnScreen()
