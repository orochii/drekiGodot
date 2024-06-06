extends BaseWindow

@export var parent:ShopMenu
@export var details:Control

@export var container:Container
@export var itemTemplate:PackedScene

var currentItems:Array
var itemList:Array
var lastSelected

func _getItemList():
	match parent.currentShopMode:
		ShopMenu.EShopMode.BUY:
			return parent.availableItemsList
		ShopMenu.EShopMode.SELL:
			var _ary = []
			for entry in Global.State.party.inventory:
				var _item = Global.Db.getItem(entry.id)
				_ary.append(_item)
			return _ary

func itemCanBarter(i):
	match parent.currentShopMode:
		ShopMenu.EShopMode.BUY:
			var _price = Global.State.party.getItemPrice(i.price, false)
			return Global.State.party.gold >= _price
		ShopMenu.EShopMode.SELL:
			return i.canSell
	return true

func open():
	# Cache current index
	var _idx = currentItems.find(lastSelected)
	if _idx < 0: _idx = 0
	# Clear old items
	for c in currentItems:
		c.queue_free()
	currentItems.clear()
	# Get list again
	itemList = _getItemList()
	# Instantiate items
	for i in itemList:
		var inst = itemTemplate.instantiate()
		container.add_child(inst)
		var _text = i.getName()
		var _icon = i.icon
		inst.setup(_text,_icon)
		inst.pressed.connect(_onSelect)
		currentItems.append(inst)
		inst.setEnabled(itemCanBarter(i))
	# Setup neighbors
	UIUtils.setVNeighbors(currentItems)
	# Select current
	currentItems[mini(_idx,currentItems.size()-1)].grab_focus()
	parent.goto(self)

func close():
	repositionCursor(null)
	# Clear old items
	for c in currentItems:
		c.queue_free()
	currentItems.clear()
	parent.goto(parent.shopCommand)

func _process(delta):
	if _isActive():
		if Input.is_action_just_pressed("action_cancel"):
			Global.Audio.playSFX("cancel")
			close()
		var focused = get_viewport().gui_get_focus_owner()
		if currentItems.has(focused):
			if lastSelected != focused:
				var _idx = currentItems.find(focused)
				details.setItem(itemList[_idx], false)
			lastSelected = focused
			repositionCursor(focused)
		else:
			if lastSelected != null: lastSelected.grab_focus()

func _isActive():
	if Global.UI.Config.visible: return false
	return parent.currentActiveScreen == self

func _onSelect():
	var focused = get_viewport().gui_get_focus_owner()
	if currentItems.has(focused):
		if focused.enabled:
			Global.Audio.playSFX("decision")
			var _idx = currentItems.find(focused)
			details.setItem(itemList[_idx], true)
			parent.goto(details)
		else:
			Global.Audio.playSFX("buzzer")
