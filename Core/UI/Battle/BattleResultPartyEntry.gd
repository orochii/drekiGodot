extends Control
class_name BattleResultPartyEntry

@export var nameLabel:Label
@export var expNum:Label
@export var expBar:ExpChangeBar
@export var appNum:Label
@export var appBar:ExpChangeBar
@export var changeLabel:Label

func setup(actor:GameActor, expChange:int, appChange:int):
	# Set name
	nameLabel.text = actor.getName()
	expNum.text = "%d" % expChange
	appNum.text = "%d" % appChange
	# Setup bars
	var expPerc = actor.getCurrLvlPerc()
	var expChangePerc = actor.getCurrLvlPerc(expChange) - expPerc
	var appPerc = actor.apPerc * 0.01
	var appChangePerc = appChange * 0.01
	expBar.setup(expPerc, expChangePerc)
	appBar.setup(appPerc, appChangePerc)
	var str = ""
	if (expPerc+expChangePerc) > 1:
		str += "Level Up! "
	if (appPerc+appChangePerc) > 1:
		str += "AP Up! "
	changeLabel.text = str
