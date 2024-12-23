extends Button
class_name EquipEntry

@export var itemIcon : NinePatchRect
@export var itemName : Label
@export var itemNum : Label

var parentMenu:CharacterEquipScreen
var entry:GameInventoryEntry = null
var data:EquipItem = null
var canUse:bool = false

func setup(_entry:GameInventoryEntry,p:CharacterEquipScreen):
	if(_entry != null):
		entry = _entry
		data = Global.Db.getItem(entry.id)
	parentMenu = p
	_refresh()

func setCanUse(v:bool):
	canUse = v
	if v: 
		modulate = Global.Db.systemColors[&"enabled"]
	else: 
		modulate = Global.Db.systemColors[&"disabled"]

func getCategory():
	if(data==null):return Global.EItemCategory.MEDICINE
	return data.category
func getSlot():
	if(data==null):return null
	return data.slot

func _refresh():
	if(entry==null):
		itemIcon.texture = null
		itemName.text = "<Remove>"
		itemNum.text = ""
		return
	itemNum.text = "%d"%entry.amount
	if(data==null): return
	itemIcon.texture = data.icon
	itemName.text = data.getName()
	#

func _on_pressed():
	if(parentMenu != null):
		Global.Audio.playSFX("equip")
		parentMenu.equip(data)
