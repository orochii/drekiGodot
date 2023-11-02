extends Control
class_name BattleMemberStatus

const BAR_ANIM_FRAMES = 10.0

class Values:
	var _show:Vector2i
	var _curr:Vector2i
	var _last:Vector2i
	
	func _setup(value,max):
		_curr = Vector2i(value,max)
		_show = Vector2i(value,max)
		_last = Vector2i(0, 0)
	
	func _setCurrent(value,max):
		_curr = Vector2i(value,max)
	
	func _updateValues(_bar,_label):
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



@export var face:NinePatchRect
@export var hpBar:NinePatchRect
@export var hpLabel:Label
@export var mpBar:NinePatchRect
@export var mpLabel:Label
@export var cpBar:Control

var battler:Battler
var hpValues:Values = Values.new()
var mpValues:Values = Values.new()

func setup(b:Battler):
	battler = b
	refreshBattler()
	refreshStatusImmediate()

func refreshBattler():
	if(battler != null):
		face.texture = battler.battler.getSmallFace()

func refreshStatusImmediate():
	if(battler != null):
		hpValues._setup(battler.battler.currHP, battler.battler.getMaxHP())
		mpValues._setup(battler.battler.currMP, battler.battler.getMaxMP())
	refreshStatus()

func refreshStatus():
	if(battler != null):
		hpValues._setCurrent(battler.battler.currHP, battler.battler.getMaxHP())
		mpValues._setCurrent(battler.battler.currMP, battler.battler.getMaxMP())
		hpValues._updateValues(hpBar,hpLabel)
		mpValues._updateValues(mpBar,mpLabel)
		# Update CP
		cpBar.scale.x = battler.atbValue

func _process(delta):
	refreshStatus()
