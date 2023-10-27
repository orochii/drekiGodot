extends Node
class_name InputManager

const MAPPING_MIRRORS = {
	"ui_left"	:	"move_left",
	"ui_right"	:	"move_right",
	"ui_up"		:	"move_up",
	"ui_down"	:	"move_down",
	"ui_accept"	:	"action_ok",
	"ui_select"	:	"action_extra",
	"ui_cancel"	:	"action_cancel",
}

var lastInputKind : int = -1

func _ready():
	lastInputKind = -1
	mirrorActionsToUIMappings()

func _process(delta):
	if Input.is_action_just_pressed("sys_snap"):
		Global.saveScreenshot()
	if Input.is_action_just_pressed("sys_config"):
		Global.UI.Config.open(false)

func _input(event):
	if event is InputEventKey:
		lastInputKind = -1
	if event is InputEventJoypadButton:
		# TODO: Different joypad support, afaik no easy way to autodetect.
		lastInputKind = 0
	if event is InputEventJoypadMotion:
		var m = event as InputEventJoypadMotion
		if absf(m.axis_value) > 0.5:
			lastInputKind = 0

func mirrorActionsToUIMappings():
	for uiMap in MAPPING_MIRRORS:
		InputMap.action_erase_events(uiMap)
		var events = InputMap.action_get_events(MAPPING_MIRRORS[uiMap])
		for ev in events:
			InputMap.action_add_event(uiMap, ev)

func serializeBindings() -> Dictionary:
	var actions = InputMap.get_actions()
	var bindingData = {}
	for action in actions:
		if action.begins_with("ui_"): continue
		if action.begins_with("sys_"): continue
		var events = InputMap.action_get_events(action)
		var actionData = []
		for ev in events:
			if ev is InputEventKey:
				var keyEv = ev as InputEventKey
				var _e = {
					"type" : "key",
					"physical_keycode" : keyEv.physical_keycode
				}
				actionData.append(_e)
			elif ev is InputEventJoypadButton:
				var joyEv = ev as InputEventJoypadButton
				var _e = {
					"type" : "joyButton",
					"idx" : joyEv.button_index,
					"pressure" : joyEv.pressure
				}
				actionData.append(_e)
			elif ev is InputEventJoypadMotion:
				var joyEv = ev as InputEventJoypadMotion
				var _e = {
					"type" : "joyMotion",
					"axis" : joyEv.axis,
					"value": joyEv.axis_value
				}
				actionData.append(_e)
		bindingData[action] = actionData
	return bindingData

func deserializeBindings(bindingData : Dictionary):
	for action in bindingData:
		var events = bindingData[action]
		InputMap.action_erase_events(action)
		for event in events:
			match event["type"]:
				"key":
					var _ev = InputEventKey.new()
					_ev.keycode = 0
					_ev.physical_keycode = event["physical_keycode"]
					InputMap.action_add_event(action, _ev)
				"joyButton":
					var _ev = InputEventJoypadButton.new()
					_ev.button_index = event["idx"]
					_ev.pressure = event["pressure"]
					InputMap.action_add_event(action, _ev)
				"joyMotion":
					var _ev = InputEventJoypadMotion.new()
					_ev.axis = event["axis"]
					_ev.axis_value = event["value"]
					InputMap.action_add_event(action, _ev)
	mirrorActionsToUIMappings()
