extends Control
class_name BattleMemberStatus

const BAR_ANIM_FRAMES = 10.0

@export var face:NinePatchRect
@export var hpBar:NinePatchRect
@export var hpLabel:Label
@export var mpBar:NinePatchRect
@export var mpLabel:Label
@export var cpBar:Control

var battler:Battler
var showHP:Vector2i
var currHP:Vector2i
var lastHP:Vector2i
var showMP:Vector2i
var currMP:Vector2i
var lastMP:Vector2i

func setup(b:Battler):
	battler = b
	refreshBattler()
	refreshStatusImmediate()

func refreshBattler():
	if(battler != null):
		face.texture = battler.battler.getSmallFace()

func refreshStatusImmediate():
	if(battler != null):
		currHP = Vector2i(battler.battler.currHP, battler.battler.getMaxHP())
		showHP = Vector2i(currHP.x, currHP.y)
		lastHP = Vector2i(0,0)
		currMP = Vector2i(battler.battler.currMP, battler.battler.getMaxMP())
		showMP = Vector2i(currMP.x, currMP.y)
		lastMP = Vector2i(0,0)
	refreshStatus()

func refreshStatus():
	if(battler != null):
		currHP = Vector2i(battler.battler.currHP, battler.battler.getMaxHP())
		currMP = Vector2i(battler.battler.currMP, battler.battler.getMaxMP())
		_updateValues(lastHP,currHP,showHP,hpBar,hpLabel)
		_updateValues(lastMP,currMP,showMP,mpBar,mpLabel)
		# Update CP
		cpBar.scale.x = battler.atbValue

func _process(delta):
	refreshStatus()

func _updateValues(_last,_curr,_show,_bar,_label):
	if(_last != _curr):
		var p = (_show.x * 1.0) / _show.y
		_setBarWidth(_bar, p)
		_label.text = "%d" % _show.x
		# Update values
		if(_curr != _show):
			var dx = roundi(abs(_curr.x - _last.x) / BAR_ANIM_FRAMES)
			if dx < 2: dx = 2
			_show.x = move_toward(_show.x, _curr.x, dx)
			var dy = roundi(abs(_curr.x - _last.x) / BAR_ANIM_FRAMES)
			if dy < 2: dy = 2
			_show.y = move_toward(_show.y, _curr.y, dy)
		else:
			_last.x = _curr.x
			_last.y = _curr.y

func _setBarWidth(bar:NinePatchRect, percent:float):
	var size = bar.texture.get_size()
	var px:int = roundi(percent * 31)
	bar.region_rect.size.x = px
	bar.region_rect.size.y = size.y
	bar.size.x = px
