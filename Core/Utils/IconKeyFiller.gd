@tool
extends Node

@export_multiline var keys : String
@export var targetLib : IconLibrary
@export var run = false

func _process(delta):
	if run: return
	if targetLib == null: return
	if (Engine.is_editor_hint()):
		run = true
		targetLib.keyAdd(keys)
