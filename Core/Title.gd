extends Node

@export var fileMenu:FileMenu
@export var buttons:Array[Button]

func _ready():
	Global.Audio.stopBGM()
	# 
	buttons[0].visible = Global.saveExist("autosave")
	buttons[2].visible = Global.getSaveList().size() != 0
	buttons[4].visible = false
	await get_tree().create_timer(1).timeout
	#
	for b in buttons:
		if b.visible:
			b.grab_focus()
			break

func _on_continue_pressed():
	Global.loadGame("autosave")
func _on_new_pressed():
	Global.newGame()
	print("Loading starting map.")
	Global.Scene.transfer(Global.Db.startingScene.resource_path)
func _on_load_pressed():
	fileMenu.open(1, false)
func _on_config_pressed():
	pass
func _on_extras_pressed():
	pass
func _on_exit_pressed():
	Global.Scene.quit()
