extends Area3D
class_name Trigger

@export var pages : Array[BaseEvent]
var currentEvent : BaseEvent

func _ready():
	# Register to switch/variable change signal
	Global.State.onSwitchChange.connect(_onSwitchChange)
	Global.State.onVariableChange.connect(_onVariableChange)
	refreshPage(true)

func _exit_tree():
	# Unregister to signals
	Global.State.onSwitchChange.disconnect(_onSwitchChange)
	Global.State.onVariableChange.disconnect(_onVariableChange)

func refreshPage(immediate:bool=false):
	currentEvent = null
	for i in range(pages.size()-1, -1, -1):
		var p = pages[i]
		if p.check():
			currentEvent = p
			break
	# Disable all pages
	for p in pages:
		if(p != null): p.visible = currentEvent==p
	# Setup current event
	if currentEvent != null: currentEvent.setup(immediate)

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
