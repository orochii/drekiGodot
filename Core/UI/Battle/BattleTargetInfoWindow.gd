extends Control
class_name BattleTargetInfoWindow

@export var nameLabel:Label
@export var hpNum:Label
@export var mpNum:Label
@export var hpLabel:Label
@export var mpLabel:Label

var battler:Battler

func setup(b:Battler):
	battler = b
	if b==null:
		nameLabel.text = ""
		hpNum.text = ""
		mpNum.text = ""
		hpLabel.visible = false
		mpLabel.visible = false
		_disconnectToUI()
	else:
		nameLabel.text = b.battler.getName()
		_refreshHp()
		_refreshMp()
		hpLabel.visible = true
		mpLabel.visible = true
		_connectToUI()

func _refreshHp():
	hpNum.text = "%d/%d" % [battler.battler.currHP, battler.battler.getMaxHP()]
func _refreshMp():
	mpNum.text = "%d/%d" % [battler.battler.currMP, battler.battler.getMaxMP()]

func _connectToUI():
	if !Global.UI.onHpChange.is_connected(_onHpChange):
		Global.UI.onHpChange.connect(_onHpChange)
		Global.UI.onMpChange.connect(_onMPChange)
		_onHpChange(battler,true)
		_onMPChange(battler,true)

func _disconnectToUI():
	if Global.UI.onHpChange.is_connected(_onHpChange):
		Global.UI.onHpChange.disconnect(_onHpChange)
		Global.UI.onMpChange.disconnect(_onMPChange)

func _onHpChange(b,max):
	if battler==null: return
	if b != battler.battler: return
	_refreshHp()
func _onMPChange(b,max):
	if battler==null: return
	if b != battler.battler: return
	_refreshMp()

func _exit_tree():
	_disconnectToUI()
