extends Area3D
class_name FloorGate

@export_flags_3d_render var layers

func _on_body_entered(body):
	if body == Global.Player && Global.Player.isReady:
		setLayers()

func setLayers():
	Global.Camera.setLayers(layers)
