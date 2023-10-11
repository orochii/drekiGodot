extends Control
class_name PartyMenu

@export var screens : Array[MenuScreen]
@export var legends : InputLegends

func _ready():
	visible = false

func open(idx:int = 0):
	setScreen(idx)
	visible = true
	Global.Scene.askPause(self)

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
