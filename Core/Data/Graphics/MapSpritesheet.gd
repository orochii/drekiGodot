@tool
extends Spritesheet
class_name MapSpritesheet

@export var collection : Array[MapSpritesheetEntry]

func initialize():
	initializeDictionary(collection)
