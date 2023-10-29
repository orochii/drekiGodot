extends AudioStreamPlayer
class_name LoopingAudioStream

var audio : AudioManager
@export var loopPoint : LoopData = null

var volume : float = 0
var fadeState : float = 1
var fadeDuration : float = 0

func _ready():
	audio = Global.Audio
	if audio != null && stream != null:
		loopPoint = audio.audioData.getLoop(stream)
func _process(delta):
	# loop process
	if loopPoint != null && loopPoint.loopLength > 0:
		var pos = self.get_playback_position()
		if (pos > loopPoint.loopStart+loopPoint.loopLength):
			play(pos - loopPoint.loopLength)
	# fade process
	if (fadeDuration > 0):
		fadeState = move_toward(fadeState, volume, delta/fadeDuration)
		volume_db = audio._percToDb(fadeState)
		if fadeState == volume: 
			fadeDuration = 0
			if(fadeState==0): playing = false

func fadeIn(duration : float):
	playing = true
	fadeState = 0
	fadeDuration = duration
func fadeOut(duration : float):
	volume = 0
	fadeState = 1
	fadeDuration = duration
func fadingOut():
	return fadeDuration > 0 && volume==0

func playFromPos(pos:float):
	play(pos)
	self.stream_paused = true
	await get_tree().create_timer(0.1).timeout
	if (fadeDuration > 0): volume_db = audio._percToDb(fadeState)
	else: volume_db = audio._percToDb(volume)
	self.stream_paused = false
	seek(pos)
