extends Character
class_name NPC

@export var pages : Array[BaseEvent]
var currentEvent : BaseEvent

func _ready():
	# Register to switch/variable change signal
	Global.State.onSwitchChange.connect(_onSwitchChange)
	Global.State.onVariableChange.connect(_onVariableChange)
	refreshPage()
func _exit_tree():
	# Unregister to signals
	Global.State.onSwitchChange.disconnect(_onSwitchChange)
	Global.State.onVariableChange.disconnect(_onVariableChange)

func refreshPage():
	currentEvent = null
	for i in range(pages.size()-1, -1, -1):
		var p = pages[i]
		if p.check():
			currentEvent = p
			break
	# Disable all pages
	for p in pages:
		if(p != null): p.visible = currentEvent==p
	# Setup page (visuals, etc)
	if currentEvent != null:
		self.graphic.spritesheet = currentEvent.graphic
		self.setCollision(currentEvent.collision)
	else:
		self.graphic.spritesheet = null
		self.setCollision(false)

func _onSwitchChange(id:int, v:bool):
	refreshPage()
func _onVariableChange(id:int, v:int):
	refreshPage()

func onInteract():
	if (currentEvent != null):
		if currentEvent.activation == BaseEvent.EActivation.INTERACT:
			currentEvent.execute()

func onTouch():
	if (currentEvent != null):
		if currentEvent.activation == BaseEvent.EActivation.PLAYER_TOUCH:
			currentEvent.execute()
