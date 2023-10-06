extends Resource
class_name AudioData

@export var loops : Array[LoopData] = []
@export var systemSFX : Array[SystemAudioEntry]

var initialized : bool = false
var dict : Dictionary

func initialize():
	dict = {}
	for l in loops: dict[l.stream.resource_path] = l
	initialized = true

func getLoop(stream : AudioStream) -> LoopData:
	if (initialized == false): initialize()
	if dict.has(stream.resource_path): return dict[stream.resource_path]
	return null
