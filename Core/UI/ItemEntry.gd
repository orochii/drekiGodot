extends Button
class_name ItemEntry

signal itemSelected(obj:ItemEntry,item:BaseItem,entry:GameInventoryEntry)

@export var itemIcon : NinePatchRect
@export var itemName : Label
@export var itemNum : Label

var entry:GameInventoryEntry = null
var data:BaseItem = null
var canUse:bool = false

func setup(_entry:GameInventoryEntry):
	entry = _entry
	data = Global.Db.getItem(entry.id)
	_refresh()

func setEnabled(inBattle:bool):
	var v = false
	if (data != null): v = data.isUseable(inBattle)
	canUse = v
	modulate.a = 1 if v else 0.5

func getCategory():
	if(data==null):return Global.EItemCategory.MEDICINE
	return data.category

func _process(delta):
	pass

func _refresh():
	if(entry==null): return
	itemNum.text = "%d"%entry.amount
	if(data==null): return
	itemIcon.texture = data.icon
	itemName.text = data.getName()

func _on_pressed():
	print("Item use")
	itemSelected.emit(self,data,entry)
