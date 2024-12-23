extends Control
class_name NamingPopup

@export var nameLabel:Label
@export var keyboard:VisualKeyboard
@export var invalidCharacters:String = ""
@export var cancelLegend:Control
@export var canCancel:bool = false

var original_text = ""
var max_letters = 0
var last_focus = null
var onSubmit:Callable
var curr_case = false
var temp_case = false

func pop(payload:Dictionary):
	cancelLegend.visible = canCancel
	last_focus = get_viewport().gui_get_focus_owner()
	original_text = payload["name"]
	nameLabel.text = "%s" % original_text
	if(payload.has("max")): max_letters = payload["max"]
	visible = true
	curr_case = false
	keyboard.changeCase(curr_case)
	keyboard.setFocus()
	keyboard.onKeyPressed = onKeyPressed

func onCancel():
	nameLabel.text = ""
	submit()
func submit():
	visible = false
	last_focus.grab_focus()
	var payload = {
		"name" : nameLabel.text
	}
	onSubmit.call(payload)

func onKeyPressed(key:StringName):
	match key:
		&"BACK":
			if nameLabel.text.length() != 0:
				nameLabel.text = nameLabel.text.substr(0,nameLabel.text.length()-1)
				Global.Audio.playSFX("decision")
		&"TAB":
			nameLabel.text = "%s" % original_text
			Global.Audio.playSFX("decision")
		&"CASE":
			curr_case = !curr_case
			keyboard.changeCase(curr_case)
			Global.Audio.playSFX("decision")
		&"IME":
			Global.Audio.playSFX("cursor")
			pass
		&"SHFT":
			temp_case = true
			curr_case = !curr_case
			keyboard.changeCase(curr_case)
			Global.Audio.playSFX("cursor")
			return
		&"ENTER":
			submit()
			Global.Audio.playSFX("decision")
		_:
			if invalidCharacters.contains(key):
				Global.Audio.playSFX("buzzer")
			else:
				nameLabel.text += key
				Global.Audio.playSFX("decision")
	if temp_case:
		temp_case = false
		curr_case = false
		keyboard.changeCase(curr_case)

func _process(delta):
	if !visible: return
	# Close
	if canCancel && Input.is_action_just_pressed("action_extra"):
		onCancel()
		return
	# Capitals
	if Input.is_action_just_pressed("action_menu"):
		onKeyPressed(&"CASE")
		return
	# Delete
	if Input.is_action_just_pressed("action_cancel"):
		if canCancel && nameLabel.text.length()==0:
			onCancel()
		onKeyPressed(&"BACK")
		return
	# Default
	if Input.is_action_just_pressed("action_select"):
		onKeyPressed(&"TAB")
		return
	# Finish
	if Input.is_action_just_pressed("action_start"):
		onKeyPressed(&"ENTER")
		return
