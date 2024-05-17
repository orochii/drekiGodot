extends Character
class_name NPC

@export var pages : Array[BaseEvent]
var currentEvent : BaseEvent
var localVars : Dictionary = {}
var localVarKey : String

func _ready():
	localVarKey = createLocalVarKey()
	super._ready()
	# Register to switch/variable change signal
	Global.State.onSwitchChange.connect(_onSwitchChange)
	Global.State.onVariableChange.connect(_onVariableChange)
	refreshPage(true)

func isEventRunning():
	if currentEvent != null:
		return currentEvent.running
	return false

func refreshPage(immediate:bool=false):
	var prevEvent = currentEvent
	currentEvent = null
	# Find current page
	for i in range(pages.size()-1, -1, -1):
		var p = pages[i]
		if p.check():
			currentEvent = p
			break
	# Ignore if same page
	if prevEvent == currentEvent && currentEvent != null: return
	# Disable all pages
	for p in pages:
		if(p != null): 
			p.visible = currentEvent==p
			if !p.visible && p.activation==BaseEvent.EActivation.PARALLEL:
				p.looping = false
	# Setup page (visuals, etc)
	if currentEvent != null: 
		if graphic != null: 
			self.graphic.spritesheet = currentEvent.graphic
		self.state = currentEvent.graphicState
		self.setCollision(currentEvent.collision)
		currentEvent.setup(immediate)
		if currentEvent.activation==BaseEvent.EActivation.AUTOSTART: currentEvent.execute()
		if currentEvent.activation==BaseEvent.EActivation.PARALLEL: currentEvent.execute()
	else:
		if graphic != null: self.graphic.spritesheet = null
		self.setCollision(false)

func _onSwitchChange(id:StringName, v:bool):
	refreshPage()
func _onVariableChange(id:StringName, v:int):
	refreshPage()

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

func getInteractOffset():
	if currentEvent==null: return 0
	return currentEvent.interactOffset
