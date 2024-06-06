extends Control

@export var animSprite:Control
@export var contents:Control
@export var styles:Array[LabelSettings]
@export var strLabel:Label
@export var vitLabel:Label
@export var intLabel:Label
@export var agiLabel:Label

var item:EquipItem
var actor:GameActor
var newStats:Dictionary = {}
var oldStats:Dictionary = {}
var canEquip:bool = false

func setup(_item:EquipItem,_actor:GameActor):
	item = _item
	actor = _actor
	canEquip = actor.canEquip(item)
	var idx = _determineIdx()
	_refreshGraphic()
	_refreshAdds(idx)

func _determineIdx():
	var _slotKind:Global.EquipSlot = item.slot
	var _slotData:Array[SlotData] = Global.Db.equipSlots
	for i in _slotData.size():
		var sd = _slotData[i]
		if sd.kind == _slotKind: return i
	return 0

func _refreshGraphic():
	var spritesheet = actor.getGraphic()
	animSprite.setup(spritesheet)
	if canEquip:
		animSprite.speed = 1
		animSprite.direction = 4
		contents.modulate = Global.Db.systemColors[&"enabled"]
	else:
		animSprite.speed = 0
		animSprite.direction = 0
		contents.modulate = Global.Db.systemColors[&"disabled"]

func _refreshAdds(idx):
	if canEquip:
		var equippedItem = actor.getEquip(idx)
		actor.equip(idx,item)
		newStats = _registerActorStats()
		actor.equip(idx,equippedItem)
		oldStats = _registerActorStats()
		setAdds()
	else:
		_unsetAdd(strLabel)
		_unsetAdd(agiLabel)
		_unsetAdd(vitLabel)
		_unsetAdd(intLabel)

func setAdds():
	_setAdd(strLabel,"str")
	_setAdd(agiLabel,"agi")
	_setAdd(vitLabel,"vit")
	_setAdd(intLabel,"mag")
	#setAdd(PAb,"pabs")
	#setAdd(MAb,"mabs")

func _unsetAdd(label:Label):
	label.text = "--"
	label.label_settings = styles[1]
func _setAdd(label:Label,key):
	var newStat = newStats[key]
	var oldStat = oldStats[key]
	# get style
	var style = styles[1]
	var format = "+%d"
	if newStat > oldStat: #><
		style = styles[2]
	elif newStat < oldStat:
		style = styles[0]
		format = "%d"
	# set label
	var _change = newStat - oldStat
	label.text = format % _change
	label.label_settings = style

func _registerActorStats():
	return {
		"str" : actor.getStr(),
		"vit" : actor.getVit(),
		"agi" : actor.getAgi(),
		"mag" : actor.getMag(),
		"pabs" : actor.getPhyAbs(),
		"mabs" : actor.getMagAbs()
	}
