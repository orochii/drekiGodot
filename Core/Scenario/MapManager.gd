extends Node

@export var music : SystemAudioEntry
@export var battleback : PackedScene

func _ready():
	Global.Audio.playBGM(music.getStreamName(), music.volume, music.pitch)
	Global.State.currentBattleback = battleback.resource_path
