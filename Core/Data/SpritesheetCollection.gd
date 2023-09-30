extends Resource
class_name SpritesheetCollection

@export var collection : Array[Spritesheet] = []

var collectionDict : Dictionary = {}

func _init():
	if collectionDict==null: collectionDict = {}
	for a in collection:
		collectionDict[a.name] = a

func getSheet(id : StringName) -> Spritesheet:
	if collectionDict.has(id): return collectionDict[id]
	if collectionDict.has(&"base"): return collectionDict[&"base"]
	if collection.size() > 0: return collection[0]
	return null
