extends Area3D

@export_flags_3d_render var layers

func _on_body_entered(body):
	if body == Global.Player:
		Global.Camera.setLayers(layers)
