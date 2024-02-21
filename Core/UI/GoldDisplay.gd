extends Label

func _process(delta):
	if Global.State.party != null:
		var g : int = Global.State.party.gold
		text = "%d" % g
