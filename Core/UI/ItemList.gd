extends Control
class_name ItemsList

@export var container:Container
@export var itemEntryTemplate:PackedScene
@export var scroll:ScrollContainer
@export var cursor:AnimatedSprite2D
@export var catSel : NinePatchRect
@export var catSelPosRef : Control
@export var availableCategories:Array[Global.EItemCategory] = [Global.EItemCategory.MEDICINE, Global.EItemCategory.EQUIP, Global.EItemCategory.UNIQUE]

var inBattle:bool = false
var onItemSelected:Callable
var entries:Array[ItemEntry]
var filteredEntries:Array
var active:bool = false
var currCategory:int = 0

func _ready():
	cursor.visible = false
	cursor.play("default")

func _process(delta):
	if(visible==false): return
	if(active==false): return
	var focused = get_viewport().gui_get_focus_owner()
	if filteredEntries.has(focused):
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
	#UIUtils.setGridNeighbors(entries,2)
	applyFilter(0)

func refresh():
	var oldFilter = currCategory
	var oldIdx = getListIndex()
	setup()
	applyFilter(oldFilter)
	setListIndex(oldIdx)

func getFirst():
	if(filteredEntries.size() == 0): return null
	return filteredEntries[0]

func getListIndex():
	var focused = get_viewport().gui_get_focus_owner()
	return filteredEntries.find(focused)

func setListIndex(idx:int):
	Global.Audio.resetLastFocused()
	if(idx >= 0 && idx < filteredEntries.size()):
		filteredEntries[idx].grab_focus()
	else:
		var f = getFirst()
		if(f != null): f.grab_focus()

func getCurrentItem():
	var focused = get_viewport().gui_get_focus_owner()
	if filteredEntries.has(focused):
		return focused.data
	return null

func switchCatBack():
	var newCat = (currCategory + availableCategories.size() - 1) % availableCategories.size()
	applyFilter(newCat)
func switchCatForward():
	var newCat = (currCategory + 1) % availableCategories.size()
	applyFilter(newCat)

func applyFilter(newCategory:int):
	currCategory = newCategory
	repositionCatSel()
	filteredEntries.clear()
	for e in entries:
		if(e.getCategory()==availableCategories[currCategory]):
			e.visible = true
			filteredEntries.append(e)
		else:
			e.visible = false
	# Set up neighboring configuration
	UIUtils.setGridNeighbors(filteredEntries,2)
	# And then do the doodeedoo :)
	setListIndex(0)

func repositionCatSel():
	var pos = catSelPosRef.position + Vector2(currCategory * 32, 0)
	catSel.position = pos

func _onSelected(obj, item, entry):
	print("emitted item signal received")
	if !obj.canUse:
		Global.Audio.playSFX("buzzer")
		print("item can't use")
		return
	if onItemSelected.is_valid():
		print("item selected for use")
		onItemSelected.call(obj, item, entry)
