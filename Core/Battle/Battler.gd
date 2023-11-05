extends Node3D
class_name Battler

signal onAnimationWaitEnd(stateName)

const DAMAGE_POP_WAIT = 0.5
const ATB_MAX = 1
const DEFAULT_SPEED = 40
const POSITION_OFFSET = Vector3(0,0,-2)
const START_OFFSET = Vector3(0,0,-20)

@export var graphic:CharGraphic

var overrideState:StringName = &""
var overrideLoop:bool = false
var appeared:bool = true
var hidden:bool = false
var escaped:bool = false
var collapsed:bool = false
var battler:GameBattler
var battle:BattleManager
var atbValue:float
var currentAction:BattleAction = null
var turn = 0
var effectWaitTime = 0
# Position stuff
var moveSpeed = DEFAULT_SPEED
var homePosition:Vector3 = Vector3(0,0,0)
var targetPosition:Vector3 = Vector3(0,0,0)
var _startDirection:float = 0
var _oldDirection:float = 0
var direction:float = 0
# Counter stuff
var currentCounters = []
var currentCounterAction = []

func setStartDirection(a:float):
	# inst.setStartDirection(-90)
	_startDirection = a
	direction = a
	global_rotation_degrees = Vector3(0, direction, 0)
func moveToPosition(pos:Vector3):
	self.global_position = pos
	targetPosition = pos
func goToPosition(pos:Vector3):
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

func _ready():
	graphic.onLoop.connect(_onGraphicLoop)
	graphic.onFrame.connect(_onGraphicFrameEvent)

func playPose(pose,loop):
	overrideState = pose
	overrideLoop = loop
	graphic.setNewState(getCurrentPose())
func _onGraphicLoop(_state:StringName):
	onAnimationWaitEnd.emit(_state)
	if !overrideLoop:
		overrideState = &""
		graphic.setNewState(getCurrentPose())
func _onGraphicFrameEvent(ev:StringName, idx:int):
	if ev==&"end":
		onAnimationWaitEnd.emit(getCurrentPose())

func _process(delta):
	if effectWait():
		effectWaitTime -= delta
	# - Pose update
	graphic.state = getCurrentPose()
	# - Movement
	if moving():
		var dir = targetPosition - global_position
		look_at(global_position - dir, Vector3.UP)
		var deg = global_rotation_degrees
		deg.x = 0; deg.z = 0
		global_rotation_degrees = deg
		global_position = global_position.move_toward(targetPosition, moveSpeed*delta)
		if !moving():
			global_rotation_degrees = Vector3(0, direction, 0)

# a
func cacheDirection():
	_oldDirection = direction
# This should be called at start of action
func lookAtTarget(targetPos:Vector3):
	var dir = targetPos - global_position
	look_at(global_position - dir, Vector3.UP)
	var deg = global_rotation_degrees
	direction = deg.y
	deg.x = 0; deg.z = 0
	global_rotation_degrees = deg
#
func lookAtTargets(targets:Array[Battler]):
	if targets.size()==0: return
	var pos = Vector3(0,0,0)
	for t in targets: pos += t.global_position
	pos /= targets.size()
	lookAtTarget(pos)
# Run upon end of movement
func resetDirection():
	direction = _oldDirection
	var deg = Vector3(0,direction,0)
	global_rotation_degrees = deg

func moving():
	return global_position != targetPosition

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
	turn += 1

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

func clearCounters():
	currentCounters.clear()
	currentCounterAction.clear()
func checkCounter(user:Battler,effect:BaseEffect,targets:Array[Battler]):
	var fs = battler.getFeatures()
	for f in fs:
		if f is CounterFeature:
			var counter = f as CounterFeature
			if !currentCounters.has(counter):
				if counter.valid(self,user,effect,targets):
					var newAction = BattleAction.new()
					newAction.battler = self
					newAction.action = counter.action
					newAction.scope = counter.action.targetScope
					if counter.targetCounteredBattler:
						newAction.selectSpecificTarget(user)
					else:
						newAction.selectRandomTarget()
					var counterTargets = newAction.resolveTargets()
					newAction.targets = counterTargets
					currentCounterAction.append(newAction)
				currentCounters.append(counter)

func pickAction():
	var actionScript:ActionScript = battler.pickActionScript(battle)
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

func escape():
	battle.battlerEscape(self)
	escaped = true
func damagePop(eff):
	battle.spawnDamagePop(self,eff)
	effectWaitTime = DAMAGE_POP_WAIT

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
func getUp():
	if !collapsed: return
	collapsed = false
	var data = battler.getData()
	if data is Enemy:
		var enemy = data as Enemy
		if enemy.collapseEffect != null:
			pass
	graphic.visible = true
func collapse():
	if collapsed: return
	collapsed = true
	var data = battler.getData()
	if data is Enemy:
		var enemy = data as Enemy
		if enemy.collapseEffect != null:
			var eff = enemy.collapseEffect.instantiate()
			get_parent().add_child(eff)
			graphic.visible = false
			eff.setup(graphic)
			return

func getCurrentPose():
	if overrideState != &"": return overrideState
	return getCurrentState()
func getCurrentState():
	if battler.isDead():
		return &"dead"
	# TODO: Set based on current altered status effect
	if moving():
		return &"moving"
	return &"base"

func cantTarget():
	return hidden || !appeared

func isHidden():
	return !appeared || escaped || !graphic.visible

func effectWait():
	return effectWaitTime > 0
