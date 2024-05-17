extends Control

@export var buttons:Array[Button]
@export var listBox:Control
@export var cursor:Node

func _ready():
	UIUtils.setVNeighbors(buttons)
	visible = false

func _process(delta):
	if !visible: return
	#
	if Input.is_action_just_pressed("action_cancel"):
		close()
	#
	var v = get_viewport().gui_get_focus_owner()
	if buttons.has(v):
		cursor.global_position = v.global_position

func open():
	visible = true
	buttons[0].grab_focus()

func close():
	visible = false

func _on_switches_pressed():
	listBox.mode = &"switch"
	listBox.regen()
	listBox.visible = true

func _on_variables_pressed():
	listBox.mode = &"variable"
	listBox.regen()
	listBox.visible = true
