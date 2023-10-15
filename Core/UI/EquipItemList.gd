extends ScrollContainer
class_name EquipItemList

@export var container:Container
@export var equipEntryTemplate:PackedScene
@export var equipScreen:CharacterEquipScreen
var equipEntries:Array
var slot:Global.EquipSlot
var actor:GameActor
var idx:int

func _process(delta):
	if(visible==false):return
	# Scroll to focused control
	var focused = get_viewport().gui_get_focus_owner()
	if equipEntries.has(focused):
		ensure_control_visible(focused)
	# Close
	if(Input.is_action_just_pressed("action_cancel")):
		equipScreen.onListClose()

func showMenu():
	visible = true
	if equipEntries.size() != 0:
		equipEntries[0].grab_focus()

func refreshList(_actor:GameActor,_idx):
	actor = _actor
	idx = _idx
	slot = Global.Db.equipSlots[idx].kind
	for e in equipEntries: e.queue_free()
	equipEntries.clear()
	var items : Array = Global.State.party.inventory
	for i in items:
		var item = Global.Db.getItem(i.id)
		if filter(item):
			var inst = equipEntryTemplate.instantiate()
			inst.setup(i,equipScreen)
			container.add_child(inst)
			equipEntries.append(inst)
	# Add remove
	var inst = equipEntryTemplate.instantiate()
	inst.setup(null,equipScreen)
	container.add_child(inst)
	equipEntries.append(inst)
	# Update neighbor stuff
	UIUtils.setVNeighbors(equipEntries)

func filter(item:BaseItem):
	if item is EquipItem:
		var e = item as EquipItem
		if e.slot != slot: return false
		if actor.canEquip(e): return true
	return false
