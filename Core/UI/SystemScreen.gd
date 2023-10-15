extends Node

@export var buttons : Array[Button]

var toFocus = null

func showTask(payload):
	if payload != null:
		if payload.size() > 0:
			toFocus = buttons[payload[0]]
func setFocus():
	if(toFocus != null):
		toFocus.grab_focus()
		toFocus = null
func hideTask():
	pass
func reset():
	pass

func _ready():
	UIUtils.setVNeighbors(buttons)
	pass
func _process(delta):
	pass

func _on_save_pressed():
	Global.Audio.playSFX("decision")
	Global.UI.File.open(0,true)
	Global.UI.Party.close()
func _on_load_pressed():
	Global.Audio.playSFX("decision")
	Global.UI.File.open(1,true)
	Global.UI.Party.close()
func _on_config_pressed():
	Global.Audio.playSFX("decision")
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
