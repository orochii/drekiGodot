extends Control
class_name PartyMenu

@export var screens : Array[MenuScreen]
@export var legends : InputLegends

func _ready():
	visible = false

func open(idx:int = 0, payload=null):
	Global.cacheScreenshot()
	Global.Scene.askPause(self)
	Global.Scene.performTransition()
	await get_tree().create_timer(0.05).timeout
	setScreen(idx,payload,true)
	visible = true

func close():
	for i in range(screens.size()):
		screens[i].hideScreen()
	visible = false
	Global.Scene.askUnpause(self)

func setScreen(idx:int,payload=null,skipTransition=false):
	if skipTransition==false:	
		Global.Scene.performTransition()
		await get_tree().create_timer(0.05).timeout
	for i in range(screens.size()):
		if idx==i:
			screens[i].showScreen(legends,payload)
		else:
			screens[i].hideScreen()

func _on_return(closeMenu:bool,payload=null):
	Global.Scene.performTransition()
	await get_tree().create_timer(0.05).timeout
	if closeMenu: 
		Global.freeScreenshot()
		close()
	else:
		setScreen(0,payload,true)

func _on_inventory_pressed():
	Global.Audio.playSFX("decision")
	setScreen(4)

func _on_group_pressed():
	Global.Audio.playSFX("decision")
	setScreen(5)

func _on_system_pressed():
	Global.Audio.playSFX("decision")
	setScreen(6)
