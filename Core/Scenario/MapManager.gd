extends Node

@export var music : SystemAudioEntry
@export var battleback : PackedScene
@export var gates : Array[Node3D]

func _ready():
	# Move character to gate
	if Global.State.targetGate >= 0 && Global.State.targetGate < gates.size():
		var p = Global.Player
		if p != null:
			var g = gates[Global.State.targetGate]
			p.global_position = g.global_position
			p.global_rotation = g.global_rotation
		else:
			print("player not found? I guess it hasn't run _ready yet")
		Global.State.targetGate = -1
	# Set current music
	if music != null:
		Global.Audio.playBGM(music.getStreamName(), music.volume, music.pitch)
	if battleback != null:
		Global.State.currentBattleback = battleback.resource_path
