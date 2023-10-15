extends Node

@export var music : SystemAudioEntry

func _ready():
	Global.Audio.playBGM(music.getStreamName(), music.volume, music.pitch)
