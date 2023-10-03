extends Spritesheet
class_name BattlerSpritesheet

@export var texture : Texture2D
@export var cellW : int = 64
@export var cellH : int = 64
@export var collection : Array[BattlerSpritesheetEntry]

func initialize():
	initializeDictionary(collection)
