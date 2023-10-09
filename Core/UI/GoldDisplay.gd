extends Label

func _process(delta):
	var g : int = Global.State.party.gold
	text = "%d" % g
