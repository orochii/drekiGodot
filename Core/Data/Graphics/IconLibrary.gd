extends Resource
class_name IconLibrary

@export var iconCollection : Array[IconLibraryEntry]
@export var keyCollection : Array[IconLibraryEntry]
@export var joyCollection : Array[IconLibraryEntry]
var iconCollectionDict : Dictionary
var keyCollectionDict : Dictionary
var joyCollectionDict : Dictionary
var initialized = false

func initializeDictionary():
	if (initialized): return
	iconCollectionDict = {}
	keyCollectionDict = {}
	joyCollectionDict = {}
	for entry in iconCollection:
		iconCollectionDict[entry.name] = entry
	for entry in keyCollection:
		keyCollectionDict[entry.name] = entry
	for entry in joyCollection:
		joyCollectionDict[entry.name] = entry
	initialized = true

func getIconName(entry : StringName, kind : int) -> String:
	var _i = _getIconFromCollection(iconCollectionDict,entry,kind)
	if (_i != null): return _i.resource_path
	return ""

func getActionIcon(action : StringName, kind : int = -2) -> Texture:
	if kind <= -2:
		kind = Global.Inputs.lastInputKind
	if kind < 0:
		var keyName = _getActionKeyName(action)
		if (keyName == ""): return null
		return _getIconFromCollection(keyCollectionDict,keyName, 0)
	else:
		var joyName = _getActionJoyName(action)
		if (joyName == ""): return null
		return _getIconFromCollection(joyCollectionDict,joyName, kind)

func getActionIconName(action : StringName, kind : int = -2) -> String:
	var icon = getActionIcon(action, kind)
	if icon != null: return icon.resource_path
	return ""

func _getIconFromCollection(collection : Dictionary, entry : StringName, kind : int) -> Texture:
	initializeDictionary()
	if collection.has(entry):
		var e : IconLibraryEntry = collection[entry]
		if (e.icons.size() > kind): return e.icons[kind]
		if (e.icons.size() > 0): return e.icons[0]
	return null

func _getActionKeyName(action : StringName) -> String:
	var evs : Array[InputEvent] = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventKey:
			var str = ev.as_text()
			return str
	return ""

func _getActionJoyName(action : StringName) -> String:
	var evs : Array[InputEvent] = InputMap.action_get_events(action)
	for ev in evs:
		if ev is InputEventJoypadButton or ev is InputEventJoypadMotion:
			var str = ev.as_text()
			str = str.split("(")[1].split(")")[0].split(",")[0]
			return str
	return ""
