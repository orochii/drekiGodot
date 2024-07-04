extends Area3D
class_name FloorGate

@export_flags_3d_render var layers
@export var charLayer:int = 1

func _on_body_entered(body):
	if Global.Player.isReady:
		if body == Global.Player:
			setLayers()
		if body is Character:
			body.setLayer(charLayer)

func setLayers():
	Global.Camera.setLayers(layers)
