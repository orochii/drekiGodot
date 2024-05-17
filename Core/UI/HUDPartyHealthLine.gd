extends Control
class_name HUDPartyHealthLine

@export var faceImg:NinePatchRect
@export var hpBar:NinePatchRect
@export var nameLabel:Label

var _id:StringName = &""
var _actor:GameActor = null
var _lastPerc:float = -1
var targetPos:Vector2

func refreshActor(idx:int):
	if idx >= Global.State.party.getMembers().size(): return null
	var m = Global.State.party.getMembers()[idx]
	if (m == _id): return
	_id = m
	_actor = Global.State.getActor(m)
	if _actor != null:
		faceImg.texture = _actor.getSmallFace()
		nameLabel.text = "%d: " % (idx+1) + _actor.getName()

func refresh(idx:int):
	refreshActor(idx)
	if _actor == null:
		visible = false
	else:
		visible = true
		var perc = _actor.currHP * 1.0 / _actor.getMaxHP()
		if _lastPerc != perc:
			_setBarWidth(hpBar, perc)
			_lastPerc = perc

func _setBarWidth(bar:NinePatchRect, percent:float):
	var size = bar.texture.get_size()
	var px:int = roundi(percent * 62)
	bar.region_rect.size.x = px
	#bar.region_rect.size.y = size.y
	bar.size.x = px/2
