extends Node3D
class_name Battler

const ATB_MAX = 1

@export var graphic:CharGraphic

var battler:GameBattler
var battle:BattleManager
var atbValue:float
var currentAction:BattleAction = null

func setup(_battler:GameBattler):
	battler = battler
	graphic.spritesheet = _battler.getBattleGraphic()

func _process(delta):
	pass

func updateAtb(delta,avgSpeed:int):
	var ownAgi = battler.getAgi()
	atbValue += (0.5 + ownAgi / avgSpeed) * delta

func isAtbFull():
	return atbValue > ATB_MAX

func pickAction():
	var actionScript:ActionScript = battler.pickActionScript()
	currentAction = actionScript.makeDecision(self)

func getEnemies(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if battler.isEnemy(b.battler): 
			if _stateConditionMet(b,state): ary.append(b)
	return ary

func getAllies(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if !battler.isEnemy(b.battler): 
			if _stateConditionMet(b,state): ary.append(b)
	return ary

func getAll(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if _stateConditionMet(b,state): ary.append(b)
	return ary

func _stateConditionMet(b:Battler,state:Global.ETargetState):
	if state==Global.ETargetState.ANY: return true
	return (state==Global.ETargetState.DEAD) == b.battler.isDead()
