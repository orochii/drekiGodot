extends Node

@export var container : Container
@export var itemEntryTemplate : PackedScene

var itemEntries : Array
var filteredEntries : Array
var toFocus = null

func _process(delta):
	if get_parent().visible==false: return

func showTask():
	if itemEntries != null:
		for c in itemEntries:
			c.queue_free()
	itemEntries.clear()
	var items : Array = Global.State.party.inventory
	for i in items:
		var inst = itemEntryTemplate.instantiate()
		inst.setup(i)
		container.add_child(inst)
		itemEntries.append(inst)
	applyFilter(Global.EItemCategory.MEDICINE)

func hideTask():
	pass

func setFocus():
	if(toFocus != null):
		toFocus.grab_focus()
		toFocus = null

func applyFilter(kind:Global.EItemCategory):
	filteredEntries.clear()
	for e in itemEntries:
		if(e.getCategory()==kind):
			e.visible = true
			filteredEntries.append(e)
		else:
			e.visible = false
	
	for i in range(filteredEntries.size()):
		var current:Button = filteredEntries[i]
		current.focus_neighbor_left = current.get_path()
		current.focus_neighbor_right = current.get_path()
		var prev = filteredEntries[i-1]
		var next = filteredEntries[i+1] if i+1<filteredEntries.size() else filteredEntries[0]
		current.focus_neighbor_bottom = next.get_path()
		current.focus_neighbor_top = prev.get_path()
		current.focus_next = current.focus_neighbor_bottom
		current.focus_previous = current.focus_neighbor_top
	
	var desiredIndex = min(0,filteredEntries.size()-1)
	if(desiredIndex >= 0): toFocus = filteredEntries[desiredIndex]
