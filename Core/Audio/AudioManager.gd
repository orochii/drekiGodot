extends Node3D
class_name AudioManager

const BUS_IDX_MASTER = 0
const BUS_IDX_BGM = 1
const BUS_IDX_BGS = 2
const BUS_IDX_AMB = 3
const BUS_IDX_SFX = 4

const FADE_DUR = 0.5
const CHANNELS = 2
var audioData : AudioData
var bgmChannels : Array[LoopingAudioStream] = []
var bgmChannelCurr : Array[int] = []
var bgsChannels : Array[LoopingAudioStream] = []
var bgsChannelCurr : Array[int] = []
var ambChannels : Array[LoopingAudioStream] = []
var ambChannelCurr : Array[int] = []
var systemSound : Dictionary

var lastFocusedUI = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	audioData = load("res://Data/System/audio.tres")
	for i in range(0,CHANNELS):
		bgmChannels.append(spawnNewChannel("BGM"))
		bgmChannels.append(spawnNewChannel("BGM"))
		bgmChannelCurr.append(0)
		bgsChannels.append(spawnNewChannel("BGS"))
		bgsChannels.append(spawnNewChannel("BGS"))
		bgsChannelCurr.append(0)
		ambChannels.append(spawnNewChannel("Amb"))
		ambChannels.append(spawnNewChannel("Amb"))
		ambChannelCurr.append(0)
	for sound in audioData.systemSFX:
		systemSound[sound.name] = spawnNewSystemSFX(sound)

func resetLastFocused():
	lastFocusedUI = null
func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if (lastFocusedUI != null && focused != null && focused != lastFocusedUI):
		playSFX("cursor")
	lastFocusedUI = focused

func spawnNewChannel(bus:String) -> LoopingAudioStream:
	var c = LoopingAudioStream.new()
	c.bus = bus
	c.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(c)
	return c

func spawnNewSystemSFX(sfx : SystemAudioEntry) -> AudioStreamPlayer:
	var s = AudioStreamPlayer.new()
	s.stream = sfx.stream
	s.volume_db = _percToDb(sfx.volume)
	s.pitch_scale = sfx.pitch
	s.max_polyphony = 4
	s.bus = "SFX"
	s.name = sfx.name
	s.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(s)
	return s

func playSFX(name : StringName):
	if (systemSound.has(name)):
		var s = systemSound[name]
		s.play()

# Volume control
func getMasterVol() -> float:
	return _dbToPerc(getMasterVolRaw())
func getMasterVolRaw() -> float: return AudioServer.get_bus_volume_db(BUS_IDX_MASTER)
func setMasterVol(v : float):
	AudioServer.set_bus_volume_db(BUS_IDX_MASTER, _percToDb(v))

func getBGMVol() -> float:
	return _dbToPerc(getBGMVolRaw())
func getBGMVolRaw() -> float: return AudioServer.get_bus_volume_db(BUS_IDX_BGM)
func setBGMVol(v : float):
	AudioServer.set_bus_volume_db(BUS_IDX_BGM, _percToDb(v))

func getBGSVol() -> float:
	return _dbToPerc(getBGSVolRaw())
func getBGSVolRaw() -> float: return AudioServer.get_bus_volume_db(BUS_IDX_BGS)
func setBGSVol(v : float):
	AudioServer.set_bus_volume_db(BUS_IDX_BGS, _percToDb(v))

func getAmbVol() -> float:
	return _dbToPerc(getAmbVolRaw())
func getAmbVolRaw() -> float: return AudioServer.get_bus_volume_db(BUS_IDX_AMB)
func setAmbVol(v : float):
	AudioServer.set_bus_volume_db(BUS_IDX_AMB, _percToDb(v))

func getSFXVol() -> float:
	return _dbToPerc(getSFXVolRaw())
func getSFXVolRaw() -> float: return AudioServer.get_bus_volume_db(BUS_IDX_SFX)
func setSFXVol(v : float):
	AudioServer.set_bus_volume_db(BUS_IDX_SFX, _percToDb(v))

# Track Playback
func playBGM(name : String, vol : float, pitch : float, pos : float = 0, channel : int = 0):
	var stream = load(name)
	_play(stream,vol,pitch,pos,channel,bgmChannels,bgmChannelCurr)
func stopBGM(channel:int=0):
	_stop(channel,bgmChannels,bgmChannelCurr)
func posBGM(channel:int=0):
	_pos(channel,bgmChannels,bgmChannelCurr)
func fadeOutBGM(duration:float,channel:int=0):
	_fadeOut(duration,channel,bgmChannels,bgmChannelCurr)

func playBGS(name : String, vol : float, pitch : float, pos : float, channel : int = 0):
	var stream = load(name)
	_play(stream,vol,pitch,pos,channel,bgsChannels,bgsChannelCurr)
func stopBGS(channel:int=0):
	_stop(channel,bgsChannels,bgsChannelCurr)
func posBGS(channel:int=0):
	_pos(channel,bgsChannels,bgsChannelCurr)
func fadeOutBGS(duration:float,channel:int=0):
	_fadeOut(duration,channel,bgsChannels,bgsChannelCurr)

func playAmb(name : String, vol : float, pitch : float, pos : float, channel : int = 0):
	var stream = load(name)
	_play(stream,vol,pitch,pos,channel,ambChannels,ambChannelCurr)
func stopAmb(channel:int=0):
	_stop(channel,ambChannels,ambChannelCurr)
func posAmb(channel:int=0):
	_pos(channel,ambChannels,ambChannelCurr)
func fadeOutAmb(duration:float,channel:int=0):
	_fadeOut(duration,channel,ambChannels,ambChannelCurr)

# Inner channel control definitions
func _play(stream : AudioStream, vol : float, pitch : float, pos : float, channel : int, channels : Array[LoopingAudioStream], channelCurr : Array[int]):
	channel = clampi(channel, 0, CHANNELS)
	var currChannel = channels[(channel * CHANNELS) + channelCurr[channel]]
	if (currChannel.playing):
		#
		if currChannel.stream==stream: return
		#
		if (!currChannel.fadingOut()): currChannel.fadeOut(FADE_DUR)
		channelCurr[channel] = 1 if channelCurr[channel]==0 else 0
		currChannel = channels[(channel * CHANNELS) + channelCurr[channel]]
	if stream != null:
		currChannel.stream = stream
		currChannel.loopPoint = audioData.getLoop(stream)
		currChannel.volume_db = -80
		currChannel.pitch_scale = pitch
		currChannel.play(pos)
		currChannel.fadeIn(FADE_DUR,vol)
	else:
		currChannel.stop()
		currChannel.loopPoint = null
func _stop(channel : int, channels : Array[LoopingAudioStream], channelCurr : Array[int]):
	channel = clampi(channel, 0, CHANNELS)
	var currChannel = channels[(channel * CHANNELS) + channelCurr[channel]]
	currChannel.stop()
func _pos(channel : int, channels : Array[LoopingAudioStream], channelCurr : Array[int]):
	channel = clampi(channel, 0, CHANNELS)
	var currChannel = channels[(channel * CHANNELS) + channelCurr[channel]]
	return currChannel.get_playback_position()
func _fadeOut(duration:float, channel : int, channels : Array[LoopingAudioStream], channelCurr : Array[int]):
	channel = clampi(channel, 0, CHANNELS)
	var currChannel = channels[(channel * CHANNELS) + channelCurr[channel]]
	currChannel.fadeOut(duration)

# UTILS
func _dbToPerc(db:float):
	return inverse_lerp(-80, 0, db)
func _percToDb(k:float):
	return lerpf(-80, 0, k)
func logWithBase(value, base): return log(value) / log(base)
