extends Control
class_name BattleTargetInfoWindow

@export var nameLabel:Label
@export var hpNum:Label
@export var mpNum:Label
@export var hpLabel:Label
@export var mpLabel:Label

func setup(b:Battler):
	if b==null:
		nameLabel.text = ""
		hpNum.text = ""
		mpNum.text = ""
		hpLabel.visible = false
		mpLabel.visible = false
	else:
		nameLabel.text = b.battler.getName()
		hpNum.text = "%d/%d" % [b.battler.currHP, b.battler.getMaxHP()]
		mpNum.text = "%d/%d" % [b.battler.currMP, b.battler.getMaxMP()]
		hpLabel.visible = true
		mpLabel.visible = true
