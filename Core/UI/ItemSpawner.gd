extends Node

@export var parentScreen : MenuScreen
@export var scroll : ScrollContainer
@export var container : Container
@export var itemEntryTemplate : PackedScene
@export var catSel : NinePatchRect
@export var useScreen : ItemUseSubscreen
@export var cursor : AnimatedSprite2D

var itemEntries : Array
var filteredEntries : Array
var toFocus = null
var currCategory:Global.EItemCategory = Global.EItemCategory.MEDICINE

func _process(delta):
	if parentScreen.visible==false: return
	if parentScreen.active==true:
		# Category selector thing uh yes.
		if moveLeft():
			Global.Audio.playSFX("cursor")
			var newCat = currCategory
			if currCategory != 0:
				newCat -= 1
			else:
				newCat = Global.EItemCategory.UNIQUE
			applyFilter(newCat)
			setFocus()
		elif moveRight():
			Global.Audio.playSFX("cursor")
			var newCat = currCategory
			if currCategory != Global.EItemCategory.UNIQUE:
				newCat += 1
			else:
				newCat = Global.EItemCategory.MEDICINE
			applyFilter(newCat)
			setFocus()
		# Scroll to focused control
		var focused = get_viewport().gui_get_focus_owner()
		if itemEntries.has(focused):
			scroll.ensure_control_visible(focused)
		await get_tree().process_frame
		positionCursor(focused)

func showTask(payload):
	if itemEntries != null:
		for c in itemEntries:
			c.queue_free()
	itemEntries.clear()
	var items : Array = Global.State.party.inventory
	for i in items:
		var inst = itemEntryTemplate.instantiate()
		inst.setup(i,self)
		container.add_child(inst)
		itemEntries.append(inst)
	applyFilter(Global.EItemCategory.MEDICINE)

func hideTask():
	cursor.visible = false
func reset():
	cursor.visible = false

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(10,8)
	else:
		cursor.visible = false

func setFocus():
	if(toFocus != null):
		toFocus.grab_focus()
		toFocus = null

func applyFilter(newCategory:Global.EItemCategory):
	currCategory = newCategory
	repositionCatSel()
	filteredEntries.clear()
	for e in itemEntries:
		if(e.getCategory()==currCategory):
			e.visible = true
			filteredEntries.append(e)
		else:
			e.visible = false
	# Set up neighboring configuration
	UIUtils.setVNeighbors(filteredEntries)
	# And then do the doodeedoo :)
	var desiredIndex = min(0,filteredEntries.size()-1)
	if(desiredIndex >= 0): toFocus = filteredEntries[desiredIndex]

func repositionCatSel():
	var pos = Vector2(currCategory * 32, 0)
	catSel.position = pos

func moveLeft():
	if(Input.is_action_just_pressed("cycle_left")): return true
	return Input.is_action_just_pressed("ui_left")
func moveRight():
	if(Input.is_action_just_pressed("cycle_right")): return true
	return Input.is_action_just_pressed("ui_right")

func showUse(item):
	useScreen.setItem(item)
