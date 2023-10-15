extends Resource
class_name SystemAudioEntry

@export var name : StringName
@export var stream : AudioStream
@export_range(0,1,0.1) var volume : float = 1.0
@export_range(0.5,1.5,0.1) var pitch : float = 1.0

func getStreamName():
	return stream.resource_path
