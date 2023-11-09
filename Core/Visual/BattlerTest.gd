extends Node3D

@export var battler:Battler
@export var graphic:CharGraphic
@export var weapon:WeaponSprite

func _ready():
	graphic.onLoop.connect(_onGraphicLoop)
	graphic.onFrame.connect(_onGraphicFrameEvent)

func _process(delta):
	if Input.is_action_just_pressed("action_ok"):
		graphic.setNewState(&"punch")
		battler.playPose(&"punch",false)
	if Input.is_action_just_pressed("action_cancel"):
		graphic.setNewState(&"kick")
		battler.playPose(&"kick",false)

func _onGraphicLoop(_state:StringName):
	graphic.state = &"base"

func _onGraphicFrameEvent(ev:StringName, idx:int):
	updateWeaponSprite(idx)

func updateWeaponSprite(idx):
	var s = graphic.getCurrentSheet()
	if s is BattlerSpritesheetEntry:
		var bse = s as BattlerSpritesheetEntry
		if -1 < idx && idx < bse.weaponPosition.size():
			var posData = bse.weaponPosition[idx]
			weapon.visible = true
			weapon.refreshValues(Vector2i(posData.x, posData.y),posData.z,graphic.flip_h)
		else:
			weapon.visible = false
