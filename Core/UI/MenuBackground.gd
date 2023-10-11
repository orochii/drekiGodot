extends CanvasItem

func _process(delta):
	var o = Global.Config.backOpacity
	modulate.a = o * 0.1
