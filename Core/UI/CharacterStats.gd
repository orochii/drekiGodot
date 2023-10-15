extends Control
class_name CharacterStats

@export_group("Base")
@export var face:NinePatchRect
@export var nameLabel:Label
@export var jobLabel:Label
@export var lvLabel:Label
@export var includeMax:bool = true
@export var hpLabel:Label
@export var mpLabel:Label
@export var apCount:Label
@export var apPercCount:Label

@export_group("Stats")
@export var strLabel:Label
@export var vitLabel:Label
@export var agiLabel:Label
@export var magLabel:Label
@export var pDefLabel:Label
@export var mDefLabel:Label

@export_group("EXP")
@export var expLabel:Label
@export var nextLabel:Label

var actor:GameActor = null
var data:Actor = null

func setup(_actor:GameActor):
	actor = _actor
	if (actor==null): return
	data = actor.getData()
	if (data==null): return
	
	if(face != null): face.texture = data.faceGraphic
	if(nameLabel != null): nameLabel.text = actor.name
	if(jobLabel != null): jobLabel.text = data.jobName
	refresh()

func refresh():
	if(lvLabel != null): lvLabel.text = "%d" % actor.level
	if(hpLabel != null): 
		if includeMax:
			hpLabel.text = "%d/%d" % [actor.currHP,actor.getMaxHP()]
		else:
			hpLabel.text = "%d" % [actor.currHP]
	if(mpLabel != null): 
		if includeMax:
			mpLabel.text = "%d/%d" % [actor.currMP,actor.getMaxMP()]
		else:
			mpLabel.text = "%d" % [actor.currMP]
	if(apCount != null): apCount.text = "%d" % actor.currAP
	if(apPercCount != null): apPercCount.text = "(%d%%)" % actor.apPerc
	
	if(strLabel != null): strLabel.text = "%d" % actor.getStr()
	if(vitLabel != null): vitLabel.text = "%d" % actor.getVit()
	if(agiLabel != null): agiLabel.text = "%d" % actor.getAgi()
	if(magLabel != null): magLabel.text = "%d" % actor.getMag()
	if(pDefLabel != null): pDefLabel.text = "%d%%" % actor.getPhyAbs()
	if(mDefLabel != null): mDefLabel.text = "%d%%" % actor.getMagAbs()
	
	if(expLabel != null): expLabel.text = "%d" % actor.exp
	if(nextLabel != null): nextLabel.text = "%d" % actor.getRemainingNextLvlExp()
