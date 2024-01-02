extends Spritesheet
class_name BigMapSpritesheet

@export var collection : Array[BigMapSpritesheetEntry]

func initialize():
	initializeDictionary(collection)
