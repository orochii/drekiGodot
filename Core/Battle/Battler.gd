extends Node3D
class_name Battler

const ATB_MAX = 1
const DEFAULT_SPEED = 40
const POSITION_OFFSET = Vector3(0,0,-2)
const START_OFFSET = Vector3(0,0,-20)

@export var graphic:CharGraphic

var appeared:bool = true
var hidden:bool = false
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
func goToStartPosition():
	var homePos = getHomePosition()
	var startPos = homePos + getStartOffset()
	targetPosition = startPos
func moveToStartPosition():
	var homePos = getHomePosition()
	var startPos = homePos + getStartOffset()
	moveToPosition(startPos)
func goToHome():
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
	await _updateStatusTime(delta)

func isAtbFull():
	return atbValue >= ATB_MAX

func startTurn():
	battler.advanceSkillConditions()
	await _updateStatusTurns()
func endTurn():
	currentAction = null
	battler.advanceStatesTurn()

func _updateStatusTurns():
	for ss in battler.states:
		var status:Status = Global.Db.getStatus(ss.id)
		if status.eotInterval != 0:
			if status.eotActivation == Global.EStatusActivation.TURN:
				await _executeStatusEffects(status, ss.turns)

func _updateStatusTime(delta:float):
	for ss in battler.states:
		var status:Status = Global.Db.getStatus(ss.id)
		if status.eotInterval != 0:
			if status.eotActivation == Global.EStatusActivation.MILLISECONDS:
				var milli:int = floori(ss.timer * 1000)
				if ss.lastTimer != milli:
					await _executeStatusEffects(status, milli)
					ss.lastTimer = milli
				ss.timer += delta

func _executeStatusEffects(status:Status, curr:int):
	# if on right interval, do stuff
	var c = curr % status.eotInterval
	if c == status.eotInterval:
		var action = BattleAction.new()
		action.battler = self
		action.action = status
		action.scope = Global.ETargetScope.ONE
		action.targetIdx = 0
		for effect in action.resolveActionList(0):
			await effect.execute(action)

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
			if b.cantTarget(): continue
			if _stateConditionMet(b,state): ary.append(b)
	return ary

func getAllies(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if !battler.isEnemy(b.battler): 
			if b.cantTarget(): continue
			if _stateConditionMet(b,state): ary.append(b)
	return ary

func getAll(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if b.cantTarget(): continue
		if _stateConditionMet(b,state): ary.append(b)
	return ary

func getLastIndex(tag:StringName):
	return battler.getLastIndex(tag)
func setLastIndex(tag:StringName,value):
	battler.setLastIndex(tag,value)

func _stateConditionMet(b:Battler,state:Global.ETargetState):
	if state==Global.ETargetState.ANY: return true
	return (state==Global.ETargetState.DEAD) == b.battler.isDead()

func appear():
	moveToStartPosition()
	goToHome()
	appeared = true

func cantTarget():
	return hidden || !appeared
