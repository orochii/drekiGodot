extends Button
class_name ItemEntry

@export var itemIcon : NinePatchRect
@export var itemName : Label
@export var itemNum : Label

var entry:GameInventoryEntry = null
var parentScreen
var data:BaseItem = null
var canUse:bool = false

func setup(_entry:GameInventoryEntry,p):
	entry = _entry
	data = Global.Db.getItem(entry.id)
	parentScreen = p
	_refresh()

func setCanUse(v:bool):
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
	setCanUse(false)
	if(data==null): return
	itemIcon.texture = data.icon
	itemName.text = data.name
	#
	if(data is UseableItem):
		var d = data as UseableItem
		if (d.canUse != Global.EUsePermit.BATTLE):
			setCanUse(true)

func _on_pressed():
	if(parentScreen != null):
		Global.Audio.playSFX("decision")
		parentScreen.showUse(self)
