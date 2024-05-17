extends BaseEvent

@export var nextScene:String
@export var targetGate:int = -1

func _run():
	if Global.Camera != null:
		Global.State.cameraAngle = Global.Camera.currRotation.y
	Global.State.targetGate = targetGate
	Global.Scene.transfer(fullname())
	pass

func fullname():
	return "res://Maps/" + nextScene + ".tscn"
