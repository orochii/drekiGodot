extends Control
class_name MenuScreen

@export var leftText : String
@export var rightText : String
@export var extraText : String
@export var showHelp : bool
@export var closeOnBack : bool
@export var firstSelected : Button
@export var tasks : Array[Node]
@export var payload : Array

var active:bool = false

func _ready():
	if payload != null:
		for i in range(payload.size()):
			if(payload[i] is NodePath):
				payload[i] = get_node(payload[i])

func _process(delta):
	if(Global.Scene.transitioning):return
	if !visible || !active: return
	if Input.is_action_just_pressed("action_cancel"):
		Global.Audio.playSFX("cancel")
		returnScreen()

func returnScreen():
	active = false
	get_parent()._on_return(closeOnBack,payload)
	for t in tasks:
		t.reset()

func showScreen(legends : InputLegends, payload=null):
	active = false
	get_viewport().gui_release_focus()
	if (legends != null):
		legends.setTexts(leftText,rightText,extraText,showHelp)
	for t in tasks:
		t.showTask(payload)
	visible = true
	
	if(Global.Scene.transitioning):
		await Global.Scene.onTransitionEnd
	
	get_viewport().gui_release_focus()
	for t in tasks:
		t.setFocus()
	if get_viewport().gui_get_focus_owner()==null:
		if firstSelected != null: firstSelected.grab_focus()
		else: get_viewport().gui_release_focus()
	active = true

func hideScreen():
	visible = false
	active = false
	for t in tasks:
		t.hideTask()
