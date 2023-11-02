extends Control
class_name ItemsList

@export var container:Container
@export var itemEntryTemplate:PackedScene
@export var scroll:ScrollContainer
@export var cursor:AnimatedSprite2D

var inBattle:bool = false
var onItemSelected:Callable
var entries:Array[ItemEntry]
var filteredEntries:Array
var active:bool = false
var currCategory:Global.EItemCategory = Global.EItemCategory.MEDICINE

func _ready():
	cursor.visible = false
	cursor.play("default")

func _process(delta):
	if(visible==false): return
	if(active==false): return
	var focused = get_viewport().gui_get_focus_owner()
	if entries.has(focused):
		scroll.ensure_control_visible(focused)
		cursor.global_position = focused.global_position + Vector2(2,8)
		cursor.visible = true
	else:
		cursor.visible = false

func setup():
	for e in entries: e.queue_free()
	entries.clear()
	var items : Array = Global.State.party.inventory
	for item in items:
		var inst:ItemEntry = itemEntryTemplate.instantiate()
		inst.setup(item)
		inst.setEnabled(inBattle)
		inst.itemSelected.connect(_onSelected)
		container.add_child(inst)
		entries.append(inst)
	UIUtils.setGridNeighbors(entries,2)
	applyFilter(currCategory)

func getFirst():
	if(entries.size() == 0): return null
	return entries[0]

func getListIndex():
	var focused = get_viewport().gui_get_focus_owner()
	return entries.find(focused)

func setListIndex(idx:int):
	if(idx >= 0 && idx < entries.size()):
		entries[idx].grab_focus()
	else:
		var f = getFirst()
		if(f != null): f.grab_focus()

func getCurrentItem():
	var focused = get_viewport().gui_get_focus_owner()
	if entries.has(focused):
		return focused.data
	return null

func applyFilter(newCategory:Global.EItemCategory):
	currCategory = newCategory
	repositionCatSel()
	filteredEntries.clear()
	for e in entries:
		if(e.getCategory()==currCategory):
			e.visible = true
			filteredEntries.append(e)
		else:
			e.visible = false
	# Set up neighboring configuration
	UIUtils.setGridNeighbors(filteredEntries,2)
	# And then do the doodeedoo :)
	var desiredIndex = min(0,filteredEntries.size()-1)
	if(desiredIndex >= 0): filteredEntries[desiredIndex].grab_focus()

func repositionCatSel():
	var pos = Vector2(currCategory * 32, 0)
	#catSel.position = pos

func _onSelected(obj, item, entry):
	print("emitted item signal received")
	if !obj.canUse:
		Global.Audio.playSFX("buzzer")
		print("item can't use")
		return
	if onItemSelected.is_valid():
		print("item selected for use")
		onItemSelected.call(obj, item, entry)
