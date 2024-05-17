extends Sprite3D

func setup(graphic:Sprite3D):
	texture = graphic.texture
	region_enabled = graphic.region_enabled
	region_rect = graphic.region_rect
	global_position = graphic.global_position
	global_rotation = graphic.global_rotation

func _on_animation_player_animation_finished(anim_name):
	queue_free()
