extends Control
class_name PartyMenu

@export var screens : Array[MenuScreen]
@export var legends : InputLegends

func _ready():
	visible = false

func open(idx:int = 0):
	Global.Scene.askPause(self)
	Global.Scene.performTransition()
	await get_tree().create_timer(0.05).timeout
	setScreen(idx)
	visible = true

func close():
	visible = false
	Global.Scene.askUnpause(self)

func setScreen(idx:int):
	for i in range(screens.size()):
		if idx==i:
			screens[i].showScreen(legends)
		else:
			screens[i].hideScreen()

func _on_return(closeMenu:bool):
	setScreen(0)
	if closeMenu: close()

func _on_inventory_pressed():
	setScreen(4)

func _on_group_pressed():
	setScreen(5)

func _on_system_pressed():
	setScreen(6)
