extends Resource
class_name AudioData

@export var loops : Array[LoopData] = []
@export var systemSFX : Array[SystemAudioEntry]
@export var events : Array[AudioEvent]

var initialized : bool = false
var dict : Dictionary
var registeredEvents : Dictionary

func initialize():
	dict = {}
	for l in loops: dict[l.stream.resource_path] = l
	registeredEvents = {}
	for e in events: registeredEvents[e.id] = e
	initialized = true

func getLoop(stream : AudioStream) -> LoopData:
	if (initialized == false): initialize()
	if dict.has(stream.resource_path): return dict[stream.resource_path]
	return null

func getEvent(name:StringName) -> AudioEvent:
	if (initialized == false): initialize()
	if registeredEvents.has(name): return registeredEvents[name]
	return null
