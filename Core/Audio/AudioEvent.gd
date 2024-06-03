extends Resource
class_name AudioEvent

@export var id:StringName
@export var samples:Array[AudioStream]

var _init:bool = false
var remaining:Array[AudioStream]

func initialize():
	for s in samples:
		if s is AudioStreamGenerator:
			var a:AudioStreamPlayer3D = AudioStreamPlayer3D.new()
			var gen = s as AudioStreamGenerator
			var playback:AudioStreamPlayback = a.get_stream_playback()#gen.instantiate_playback()
			var sample_hz = gen.mix_rate
			var pulse_hz = 640.0 * randf_range(0.9, 1.1)
			var phase = 0.0
			var increment = pulse_hz / sample_hz
			var frames_available = playback.get_frames_available()
			for i in range(frames_available):
				playback.push_frame(Vector2.ONE * sin(phase * TAU))
				phase = fmod(phase + increment, 1.0)
			print("I'd rather generate the buffer differently, because the playback isn't gonna work. This Generator class is stupid.")
			print("Generated sine pulse of %fhz" % pulse_hz)
	_init = true

func refill():
	remaining.append_array(samples)

func getSample() -> AudioStream:
	if(samples.size()==0): return null
	if(remaining.size()==0): refill()
	var r = randi_range(0, remaining.size()-1)
	var ret = remaining[r]
	remaining.remove_at(r)
	return ret
