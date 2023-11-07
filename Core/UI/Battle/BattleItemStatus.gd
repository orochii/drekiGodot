extends Control
class_name BattleItemStatus

@export var nameLabel:Label
@export var equip1Icon:NinePatchRect
@export var equip1Label:Label
@export var equip2Icon:NinePatchRect
@export var equip2Label:Label

var battler:Battler

func setup(b:Battler):
	nameLabel.text = b.battler.getName()
	battler = b
	refreshEquips()

func refreshEquips():
	if battler.battler is GameActor:
		var actor = battler.battler as GameActor
		var itm1 = actor.getEquip(0)
		if(itm1 != null):
			equip1Icon.texture = itm1.icon
			equip1Label.text = itm1.getName()
		else:
			equip1Icon.texture = null
			equip1Label.text = ""
		var itm2 = actor.getEquip(1)
		if(itm2 != null):
			equip2Icon.texture = itm2.icon
			equip2Label.text = itm2.getName()
		else:
			equip2Icon.texture = null
			equip2Label.text = ""
