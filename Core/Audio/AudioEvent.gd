extends Resource
class_name AudioEvent

@export var id:StringName
@export var samples:Array[AudioStream]

var remaining:Array[AudioStream]

func refill():
	remaining.append_array(samples)

func getSample() -> AudioStream:
	if(samples.size()==0): return null
	if(remaining.size()==0): refill()
	var r = randi_range(0, remaining.size()-1)
	var ret = remaining[r]
	remaining.remove_at(r)
	return ret
