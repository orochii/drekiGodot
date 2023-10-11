extends Control
class_name MenuScreen

@export var leftText : String
@export var rightText : String
@export var extraText : String
@export var showHelp : bool
@export var closeOnBack : bool
@export var firstSelected : Button
@export var tasksOnShow : Array[Node]
@export var tasksOnHide : Array[Node]

func _process(delta):
	if !visible: return
	if Input.is_action_just_pressed("action_cancel"):
		get_parent()._on_return(closeOnBack)

func showScreen(legends : InputLegends):
	if (legends != null):
		legends.setTexts(leftText,rightText,extraText,showHelp)
	if firstSelected != null: firstSelected.grab_focus()
	for t in tasksOnShow:
		t.runTask()
	visible = true

func hideScreen():
	visible = false
	for t in tasksOnHide:
		t.runTask()
