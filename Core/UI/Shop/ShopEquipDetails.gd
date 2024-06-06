extends Control

func setItem(item:EquipItem):
	var lines = get_children()
	for i in lines.size():
		var actor = Global.State.party.getMember(i)
		if actor == null:
			lines[i].visible = false
		else:
			lines[i].visible = true
			lines[i].setup(item,actor)