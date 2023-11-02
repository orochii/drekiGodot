extends Node3D
class_name Battler

const ATB_MAX = 1
const DEFAULT_SPEED = 40
const POSITION_OFFSET = Vector3(0,0,-2)
const START_OFFSET = Vector3(0,0,-20)

@export var graphic:CharGraphic

var battler:GameBattler
var battle:BattleManager
var atbValue:float
var currentAction:BattleAction = null

# Position stuff
var moveSpeed = DEFAULT_SPEED
var homePosition:Vector3 = Vector3(0,0,0)
var targetPosition:Vector3 = Vector3(0,0,0)
var _startDirection:float = 0
var direction:float = 0

func setStartDirection(a:float):
	# inst.setStartDirection(-90)
	_startDirection = a
	direction = a
	global_rotation_degrees = Vector3(0, direction, 0)
func moveToPosition(pos:Vector3):
	self.global_position = pos
	targetPosition = pos
func moveToStartPosition():
	var homePos = getHomePosition()
	var startPos = homePos + getStartOffset()
	moveToPosition(startPos)
func moveToHome():
	targetPosition = getHomePosition()
func setHomePosition(pos:Vector3):
	# inst.setHomePosition(startingPosition + (partyPositionOffset * i))
	homePosition = pos
func getHomePosition():
	var offset:Vector3 = POSITION_OFFSET * battler.getPosition()
	var d = deg_to_rad(_startDirection)
	var rotOffset = offset.rotated(Vector3(0,1,0),d)
	return homePosition + rotOffset
func getStartOffset():
	var d = deg_to_rad(_startDirection)
	return START_OFFSET.rotated(Vector3(0,1,0),d)

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
	global_position = global_position.move_toward(targetPosition, moveSpeed*delta)

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

func startTurn():
	battler.advanceSkillConditions()
func endTurn():
	atbValue = 0
	currentAction = null

func setAction(action:Resource, scope:Global.ETargetScope, targetIdx:int):
	currentAction = BattleAction.new()
	currentAction.battler = self
	currentAction.action = action
	currentAction.scope = scope
	currentAction.targetIdx = targetIdx

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

func getLastIndex(tag:StringName):
	return battler.getLastIndex(tag)
func setLastIndex(tag:StringName,value):
	battler.setLastIndex(tag,value)

func _stateConditionMet(b:Battler,state:Global.ETargetState):
	if state==Global.ETargetState.ANY: return true
	return (state==Global.ETargetState.DEAD) == b.battler.isDead()
