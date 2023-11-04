extends Control
class_name BattlerStatusHUD

const POS_MARGIN = Vector2(32,16)
const BATTLER_OFFSET = Vector2(0,8)

@export var cp:Control
@export var cpBar:NinePatchRect
@export var cpBarFull:NinePatchRect
@export var statesDisplay:StatesDisplay

var _battler:Battler

func setup(b:Battler,showCp:bool):
	_battler = b
	cp.visible = true #showCp
	statesDisplay.setup(_battler)

func _process(delta):
	if(_battler==null): return
	self.visible = !_battler.isHidden()
	updatePosition()
	updateCP()

func updatePosition():
	var min:Vector2 = POS_MARGIN
	var max:Vector2 = _battler.battle.screenSize() - POS_MARGIN
	var pos = _battler.getScreenPosition()
	var size = _battler.getScreenSize()
	size.x = 0
	var resultPosition = pos - size - BATTLER_OFFSET
	resultPosition.x = clampf(resultPosition.x, min.x, max.x)
	resultPosition.y = clampf(resultPosition.y, min.y, max.y)
	self.global_position = resultPosition

func updateCP():
	if cp.visible:
		if _battler.isAtbFull():
			cpBarFull.visible = true
			cpBar.visible= false
		else:
			cpBarFull.visible = false
			cpBar.visible= true
			_setBarWidth(cpBar, _battler.atbValue)

func _setBarWidth(bar:NinePatchRect, percent:float):
	var size = bar.texture.get_size()
	var px:int = roundi(percent * 58)
	bar.region_rect.size.x = px
	#bar.region_rect.size.y = size.y
	bar.size.x = px/2
