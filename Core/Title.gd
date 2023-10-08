extends Node

func _ready():
	await get_tree().create_timer(1).timeout
	print("Loading starting map.")
	Global.Scene.transfer(Global.Db.startingScene.resource_path)
