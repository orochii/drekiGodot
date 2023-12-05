extends Node

@export var fileMenu:FileMenu
@export var configMenu:ConfigMenu
@export var buttons:Array[Button]
@export var cursor:AnimatedSprite2D

func _ready():
	cursor.play("default")
	Global.Audio.stopBGM()
	# 
	buttons[0].visible = Global.saveExist("autosave")
	buttons[2].visible = Global.getSaveFileList().size() != 0
	buttons[4].visible = false
	await get_tree().create_timer(1).timeout
	#
	for b in buttons:
		if b.visible:
			b.grab_focus()
			break

func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if(buttons.has(focused)):
		cursor.global_position = focused.global_position + Vector2(10,8)
		cursor.visible = true
	else:
		cursor.visible = false

func _on_continue_pressed():
	Global.Audio.playSFX("load")
	Global.loadGame("autosave")
func _on_new_pressed():
	get_viewport().gui_release_focus()
	Global.Audio.playSFX("decision")
	Global.newGame()
	Global.Scene.transfer(Global.Db.startingScene.resource_path)
func _on_load_pressed():
	Global.Audio.playSFX("decision")
	fileMenu.open(1, false)
func _on_config_pressed():
	Global.Audio.playSFX("decision")
	configMenu.open(false)
func _on_extras_pressed():
	Global.Audio.playSFX("decision")
func _on_exit_pressed():
	Global.Audio.playSFX("decision")
	Global.Scene.quit()
