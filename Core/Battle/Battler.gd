extends Node3D
class_name Battler

const ATB_MAX = 1

@export var graphic:CharGraphic

var _battler:GameBattler
var atbValue:float

func setup(battler:GameBattler):
	_battler = battler
	graphic.spritesheet = _battler.getBattleGraphic()

func _process(delta):
	pass

func updateAtb(delta,avgSpeed:int):
	var ownAgi = _battler.getAgi()
	atbValue += (0.5 + ownAgi / avgSpeed) * delta

func isAtbFull():
	return atbValue > ATB_MAX
