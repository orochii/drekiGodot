extends Resource
class_name IconLibrary

@export var collection : Array[IconLibraryEntry]
var collectionDict : Dictionary
var initialized = false

func initializeDictionary():
	if (initialized): return
	collectionDict = {}
	for entry in collection:
		collectionDict[entry.name] = entry
	initialized = true

func getIcon(entry : StringName, kind : int) -> String:
	initializeDictionary()
	if collectionDict.has(entry):
		var e : IconLibraryEntry = collectionDict[entry]
		if (e.icons.size() > kind): return e.icons[kind].resource_path
		if (e.icons.size() > 0): return e.icons[0].resource_path
	return ""

func getActionIcon(action : StringName, kind : int) -> String:
	var joyName = getActionJoyName(action)
	if (joyName == ""): return ""
	return getIcon(joyName, kind)

func getActionJoyName(action : StringName) -> String:
	var evs : Array[InputEvent] = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
			var str = ev.as_text()
			str = str.split("(")[1].split(")")[0].split(",")[0]
			return str
	return ""
