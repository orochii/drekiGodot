extends Node3D
class_name Battler

@export var graphic:CharGraphic

var _battler:GameBattler

func setup(battler:GameBattler):
	_battler = battler
	graphic.spritesheet = _battler.getBattleGraphic()

func _process(delta):
	pass
