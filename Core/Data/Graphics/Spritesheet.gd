extends Resource
class_name Spritesheet

var initialized : bool = false
var collectionDict : Dictionary = {}

func getSheet(id : StringName) -> SpritesheetEntry:
	if (initialized == false): initialize()
	if collectionDict.has(id): return collectionDict[id]
	if collectionDict.has(&"base"): return collectionDict[&"base"]
	return null

func initialize():
	pass

func initializeDictionary(origCollection : Array):
	if collectionDict==null: collectionDict = {}
	for a in origCollection:
		collectionDict[a.name] = a
		a.parent = self
	initialized = true
