extends Control
class_name MenuScreen

@export var leftText : String
@export var rightText : String
@export var extraText : String
@export var showHelp : bool
@export var closeOnBack : bool
@export var firstSelected : Button
@export var tasks : Array[Node]

var active:bool = false

func _process(delta):
	if !visible || !active: return
	if Input.is_action_just_pressed("action_cancel"):
		get_parent()._on_return(closeOnBack)

func showScreen(legends : InputLegends):
	active = false
	if (legends != null):
		legends.setTexts(leftText,rightText,extraText,showHelp)
	active = true
	for t in tasks:
		t.showTask()
	visible = true
	
	if(Global.Scene.transitioning):
		await Global.Scene.onTransitionEnd
	
	get_viewport().gui_release_focus()
	for t in tasks:
		t.setFocus()
	if get_viewport().gui_get_focus_owner()==null:
		if firstSelected != null: firstSelected.grab_focus()
		else: get_viewport().gui_release_focus()

func hideScreen():
	visible = false
	active = false
	for t in tasks:
		t.hideTask()
