extends Control
class_name HUDPartyHealthLine

@export var faceImg:NinePatchRect
@export var hpBar:NinePatchRect
@export var nameLabel:Label

var targetPos:Vector2

func getActor(idx:int):
	if idx >= Global.State.party.getMembers().size(): return null
	var m = Global.State.party.getMembers()[idx]
	return Global.State.getActor(m)

func refresh(idx:int):
	var actor:GameActor = getActor(idx)
	if actor == null:
		visible = false
	else:
		visible = true
		faceImg.texture = actor.getSmallFace()
		nameLabel.text = "%d: "%idx + actor.getName()
		_setBarWidth(hpBar, actor.currHP * 1.0 / actor.getMaxHP())

func _setBarWidth(bar:NinePatchRect, percent:float):
	var size = bar.texture.get_size()
	var px:int = roundi(percent * 62)
	bar.region_rect.size.x = px
	#bar.region_rect.size.y = size.y
	bar.size.x = px/2
