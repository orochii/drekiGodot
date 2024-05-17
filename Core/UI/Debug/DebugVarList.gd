extends NinePatchRect

@export var optionTemplate:PackedScene
@export var container:VBoxContainer
@export var mode:StringName = &"switch"

var currentList = []

func regen():
	for e in currentList:
		e.queue_free()
	currentList.clear()
	var dict:Dictionary = {}
	if mode==&"switch": dict = Global.State.switches
	elif mode==&"variable": dict = Global.State.variables
	# Generate list
	for k in dict:
		var i = optionTemplate.instantiate()
		i.get_child(0).text = "%s" % k
		i.get_child(1).text = "%s" % dict[k]
		container.add_child(i)
		currentList.append(i)
