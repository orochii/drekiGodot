extends Button
class_name ItemEntry

@export var itemIcon : NinePatchRect
@export var itemName : Label
@export var itemNum : Label

var entry:GameInventoryEntry = null
var data:BaseItem = null

func setup(_entry:GameInventoryEntry):
	entry = _entry
	data = Global.Db.getItem(entry.id)
	_refresh()

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
	itemName.text = data.name
