extends Control
class_name CharacterStatChanges

@export var styles:Array[LabelSettings]
@export var Str:StatAddPair
@export var Agi:StatAddPair
@export var Vit:StatAddPair
@export var Mag:StatAddPair
@export var PAb:StatAddPair
@export var MAb:StatAddPair

var actor:GameActor = null
var newStats:Dictionary = {}
var oldStats:Dictionary = {}

func _ready():
	visible = false

func setActor(_actor:GameActor):
	actor = _actor

func refreshAdds(item,idx):
	visible = true
	var equippedItem = actor.getEquip(idx)
	actor.equip(idx,item)
	newStats = registerActorStats()
	actor.equip(idx,equippedItem)
	oldStats = registerActorStats()
	setAdds()

func setAdds():
	setAdd(Str,"str")
	setAdd(Agi,"agi")
	setAdd(Vit,"vit")
	setAdd(Mag,"mag")
	setAdd(PAb,"pabs")
	setAdd(MAb,"mabs")
func setAdd(pair:StatAddPair,key):
	var newStat = newStats[key]
	var oldStat = oldStats[key]
	var style = styles[1]
	if newStat > oldStat: #><
		style = styles[2]
	elif newStat < oldStat:
		style = styles[0]
	pair.setAdd(newStats[key],style)

func registerActorStats():
	return {
		"str" : actor.getStr(),
		"vit" : actor.getVit(),
		"agi" : actor.getAgi(),
		"mag" : actor.getMag(),
		"pabs" : actor.getPhyAbs(),
		"mabs" : actor.getMagAbs()
	}
