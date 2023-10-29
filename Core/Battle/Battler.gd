extends Node3D
class_name Battler

const ATB_MAX = 1

@export var graphic:CharGraphic

var battler:GameBattler
var battle:BattleManager
var atbValue:float
var currentAction:BattleAction = null

func getScreenPosition():
	return battle.posToScreen(self.global_position)
func getScreenSize() -> Vector2:
	return graphic.region_rect.size
func getSize() -> Vector2:
	return getScreenSize() * graphic.pixel_size

func setup(_battler:GameBattler):
	battler = _battler
	graphic.spritesheet = _battler.getBattleGraphic()

func _process(delta):
	# TODO:
	# - Movement
	pass

func updateAtb(delta,avgSpeed:int):
	var ownAgi = battler.getAgi()
	var avgFactor = ownAgi * 1.0 / avgSpeed
	var addValue = (0.5 + avgFactor) * delta
	if battler is GameEnemy && Global.Config.activeBattle:
		addValue *= 0.8
	atbValue += addValue
	if atbValue>ATB_MAX: atbValue=ATB_MAX

func isAtbFull():
	return atbValue >= ATB_MAX

func endTurn():
	atbValue = 0
	currentAction = null

func pickAction():
	var actionScript:ActionScript = battler.pickActionScript()
	if actionScript==null:
		currentAction = BattleAction.new()
		currentAction.battler = self
		currentAction.action = null
		currentAction.scope = Global.ETargetScope.ONE
		currentAction.targetIdx = 0
	else:
		currentAction = actionScript.makeDecision(self)

func pickAutoaction():
	var actionScript:ActionScript = ActionScript.new()
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
