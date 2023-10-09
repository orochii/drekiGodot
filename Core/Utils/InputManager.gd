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

func _input(event):
	if event is InputEventKey:
		lastInputKind = -1
	if event is InputEventJoypadButton: #|| event is InputEventJoypadMotion:
		# TODO: Different joypad support, afaik no easy way to autodetect.
		lastInputKind = 0
	if event is InputEventJoypadMotion:
		var m = event as InputEventJoypadMotion
		if m.axis_value > 0.5:
			lastInputKind = 0

func mirrorActionsToUIMappings():
	for uiMap in MAPPING_MIRRORS:
		InputMap.action_erase_events(uiMap)
		var events = InputMap.action_get_events(MAPPING_MIRRORS[uiMap])
		for ev in events:
			InputMap.action_add_event(uiMap, ev)
