extends Area3D
class_name Trigger

@export var pages : Array[BaseEvent]
var currentEvent : BaseEvent
var localVars : Dictionary = {}
var localVarKey : String

func _ready():
	localVarKey = createLocalVarKey()
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
		if p != null && p.check():
			currentEvent = p
			break
	# Disable all pages
	for p in pages:
		if(p != null): p.visible = currentEvent==p
	# Setup current event
	if currentEvent != null:
		currentEvent.setup(immediate)
		if currentEvent.activation==BaseEvent.EActivation.AUTOSTART: currentEvent.execute()
		if currentEvent.activation==BaseEvent.EActivation.PARALLEL: currentEvent.execute()

func _onSwitchChange(id:int, v:bool):
	refreshPage()
func _onVariableChange(id:int, v:int):
	refreshPage()

func isEventRunning():
	if currentEvent != null:
		return currentEvent.running
	return false

func onInteract():
	if (currentEvent != null && isEventRunning()==false):
		if currentEvent.activation == BaseEvent.EActivation.INTERACT:
			currentEvent.execute()

func onTouch():
	if (currentEvent != null && isEventRunning()==false):
		if currentEvent.activation == BaseEvent.EActivation.PLAYER_TOUCH:
			currentEvent.execute()

func getLocalVar(name:StringName):
	return Global.State.getLocalVar(localVarKey,name)

func setLocalVar(name:StringName, val:bool):
	Global.State.setLocalVar(localVarKey,name,val)
	refreshPage()

func createLocalVarKey():
	return Global.State.lastSceneName + ":" + self.get_path().get_concatenated_names()


func _on_body_entered(body):
	if body is PlayerWorldmap:
		var p = body as PlayerWorldmap
		p._on_touch_area_entered(self)
