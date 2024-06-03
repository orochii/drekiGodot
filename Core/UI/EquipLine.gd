extends Button
class_name EquipLine

@export var slotName:Label
@export var itemIcon:NinePatchRect
@export var itemName:Label

var idx:int
var slot:SlotData
var item:BaseItem
var parentMenu:CharacterEquipScreen
var weaponIdx:int = 0

func getKind():
	slot.kind
func setSlot(_idx:int,p):
	parentMenu = p
	idx = _idx
	var slot = Global.Db.equipSlots[idx]
	slotName.text = slot.name
	if slot.kind==Global.EquipSlot.ARMS:
		weaponIdx = idx
	else:
		weaponIdx = -1

func setup(_item:BaseItem):
	item = _item
	if(item != null):
		itemIcon.texture = item.icon
		itemName.text = item.getName()
	else:
		itemIcon.texture = null
		itemName.text = ""

func _on_pressed():
	parentMenu.onSlotSelected(idx)
