extends Node3D
class_name Battler

signal onAnimationWaitEnd(stateName)

const LOW_HP_PERCENT = 0.25
const DEFAULT_JUMP_ENTER_TIME = 0.5
const DEFAULT_JUMP_ENTER_HEIGHT = 1.5
const DEFAULT_JUMP_TIME = 0.5
const DEFAULT_JUMP_HEIGHT = 1.5
const DAMAGE_POP_WAIT = 0.5
const ATB_MAX = 1
const DEFAULT_SPEED = 15
const POSITION_OFFSET = Vector3(0,0,-1)
const START_OFFSET = Vector3(0,0,-7.5)
const FLYING_DELTAMULT = 0.125
const FLYING_BASEHEIGHT = 0.5
const FLYING_ADDHEIGHT = 0.5
const FLYING_DELTAMOVE = 0.25
const IMAGE_PER_FRAME = 16

@export var graphic:CharGraphic
@export var weapon:WeaponSprite
@export var scaler:Node3D
@export var raycast:RayCast3D
@export var afterimage:PackedScene

var overrideState:StringName = &""
var overrideLoop:bool = false
var readyForBattle:bool = false
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
var jumpStartPos:Vector3
var jumpTotalTime:float
var jumpCurrTime:float
var jumpHeight:float
var targetHeight:float = 0
var _moveSetPose:bool = false
var _startDirection:float = 0
var _oldDirection:float = 0
var direction:float = 0
# Counter stuff
var turnEffects = []
var currentCounters = []
var currentCounterAction = []
var flyingState = 0
var flyingHeight = 0.0
var afterimageEnabled = false
var afterimageWait = 0
var afterimageInterval = 0.1
var prevFramePos:Vector3

func setStartDirection(a:float):
	_startDirection = a
	direction = a
	rotation_degrees = Vector3(0, direction, 0)
func moveToPosition(pos:Vector3):
	self.position = pos
	targetPosition = pos
func goToPosition(pos:Vector3, setPose:bool):
	targetPosition = pos
	_moveSetPose = setPose
func goToStartPosition():
	var homePos = getHomePosition()
	var startPos = homePos + getStartOffset()
	#goToPosition(startPos,true)
	jump(startPos,DEFAULT_JUMP_ENTER_TIME,DEFAULT_JUMP_ENTER_HEIGHT,&"jumpForward",true)
func moveToStartPosition():
	var homePos = getHomePosition()
	var startPos = homePos + getStartOffset()
	moveToPosition(startPos)
func goToHome():
	#targetPosition = getHomePosition()
	var newPos = getHomePosition()
	if position.distance_squared_to(newPos) > 0.01:
		jump(newPos,DEFAULT_JUMP_TIME,DEFAULT_JUMP_HEIGHT,&"jumpBack")
	else:
		moveToPosition(newPos)
func setHomePosition(pos:Vector3):
	# inst.setHomePosition(startingPosition + (partyPositionOffset * i))
	homePosition = pos
func getHomePosition():
	var offset:Vector3 = POSITION_OFFSET * (battler.getPosition())
	var d = deg_to_rad(_startDirection)
	var rotOffset = offset.rotated(Vector3(0,1,0),d)
	return homePosition + rotOffset
func getGlobalHomePosition():
	return localToGlobalPosition(getHomePosition())
func localToGlobalPosition(pos:Vector3):
	var p = get_parent() as Node3D
	var rot = Quaternion.from_euler(p.global_rotation)
	return p.global_position + (rot * pos)
func getStartOffset():
	var d = deg_to_rad(_startDirection)
	return START_OFFSET.rotated(Vector3(0,1,0),d)

func getScreenPosition():
	return battle.posToScreen(self.global_position)
func getScreenSize() -> Vector2:
	return graphic.getScreenSize()
func getSize() -> Vector2:
	return graphic.getSize() * Vector2(scaler.scale.x, scaler.scale.y)

func setup(_battler:GameBattler):
	battler = _battler
	graphic.spritesheet = _battler.getBattleGraphic()
	weapon.camOverride = battle.camera.camera
	_connectToUI()

func cleanup():
	_disconnectToUI()

func _connectToUI():
	Global.UI.onHpChange.connect(_onHpChange)
	Global.UI.onMpChange.connect(_onMPChange)
	_onHpChange(battler,true)
	_onMPChange(battler,true)

func _disconnectToUI():
	Global.UI.onHpChange.disconnect(_onHpChange)
	Global.UI.onMpChange.disconnect(_onMPChange)

var _lowHp:bool = false
func _onHpChange(b,max):
	if b != battler: return
	_lowHp = battler.currHP < (battler.getMaxHP() * LOW_HP_PERCENT)
func _onMPChange(b,max):
	if b != battler: return

func _ready():
	flyingState = randf()
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
	updateWeaponSprite(idx)
	if ev==&"end":
		onAnimationWaitEnd.emit(getCurrentPose())

func setWeaponIndex(idx:int):
	if battler is GameActor:
		var actor = battler as GameActor
		actor.setCurrentWeapon(idx)
		var realIdx = actor.getCurrWeaponIdx()
		var equip = actor.getEquip(realIdx)
		# Set weapon sprite
		if equip != null:
			weapon.setSprite(equip.weaponSprite, equip.gripOffset)
		else:
			weapon.setSprite(null, Vector2i(0,0))

func updateWeaponSprite(idx):
	var s = graphic.getCurrentSheet()
	if s is BattlerSpritesheetEntry:
		var bse = s as BattlerSpritesheetEntry
		if -1 < idx && idx < bse.weaponPosition.size():
			var posData = bse.weaponPosition[idx]
			weapon.visible = true
			weapon.refreshValues(Vector2i(posData.x, posData.y), posData.z, graphic.flip_h)
		else:
			weapon.visible = false

func isFlying():
	return battler.isFlying()

func _process(delta):
	_updateFlying(delta)
	_updateAfterimage(delta)
	if effectWait():
		effectWaitTime -= delta
	# - Pose update
	graphic.state = getCurrentPose()
	# - Jumping
	if jumping():
		var t = (jumpTotalTime-jumpCurrTime) / jumpTotalTime
		# position
		position = jumpStartPos.lerp(targetPosition, t)
		prevFramePos = graphic.global_position
		# height
		var tt = (pingpong(t, 0.5) * 1)
		scaler.position.y = sin(tt*PI) * jumpHeight + flyingHeight
		# decrease
		jumpCurrTime -= delta
		if !jumping():
			rotation_degrees = Vector3(0, direction, 0)
			overrideLoop = false
			if !readyForBattle: readyForBattle = true
	# - Movement
	elif moving():
		lookAtTarget(localToGlobalPosition(targetPosition),false)
		position = position.move_toward(targetPosition, moveSpeed*delta)
		prevFramePos = graphic.global_position
		if raycast.is_colliding():
			var point = raycast.get_collision_point()
			global_position.y = point.y
		if !moving():
			rotation_degrees = Vector3(0, direction, 0)
			if !readyForBattle: readyForBattle = true

func _updateFlying(delta):
	if isFlying():
		flyingState = flyingState + (delta * FLYING_DELTAMULT)
		flyingState = flyingState - floor(flyingState)
		var h = FLYING_BASEHEIGHT + sin(flyingState*2*PI) * FLYING_ADDHEIGHT
		flyingHeight = lerp(flyingHeight, h, FLYING_DELTAMOVE*delta)
	else:
		flyingState = 0
		flyingHeight = move_toward(flyingHeight, 0, FLYING_DELTAMOVE*delta)
	scaler.position.y = flyingHeight
func _updateAfterimage(delta):
	if afterimageEnabled:
		afterimageWait-=delta
		if afterimageWait < 0:
			var i = afterimage.instantiate()
			get_parent().add_child(i)
			i.setup(graphic)
			afterimageWait = afterimageInterval
	else:
		afterimageWait = 0

# jumpTotalTime jumpCurrTime jumpStartPos jumpHeight
func jump(pos:Vector3,time:float,height:float,jumpPose=&"jumpHigh",lookAt:bool=false):
	if lookAt: lookAtTarget(localToGlobalPosition(pos),false)
	overrideState = jumpPose
	overrideLoop = true
	targetPosition = pos
	raycastFromTargetPosition()
	jumpTotalTime = time
	jumpCurrTime = time
	jumpStartPos = position
	jumpHeight = height

func raycastFromTargetPosition():
	# Query where the target position is located actually (or something)
	var space_state = get_world_3d().direct_space_state
	var _queryPos = get_parent().global_position + targetPosition
	var _origin = _queryPos + Vector3(0,2,0)
	var _target = _queryPos + Vector3(0,-3,0)
	var query = PhysicsRayQueryParameters3D.create(_origin, _target)
	query.collision_mask = raycast.collision_mask
	var result = space_state.intersect_ray(query)
	if result:
		var _diff = result.position.y - _queryPos.y
		targetPosition.y += _diff

func cacheDirection():
	_oldDirection = direction
# This should be called at start of action
func lookAtTarget(targetPos:Vector3,changeDirection:bool=true):
	var dir = targetPos - global_position
	var invDir = global_position - dir
	look_at(invDir, Vector3.UP)
	var deg = rotation_degrees
	deg.x = 0; deg.z = 0
	if(changeDirection): 
		direction = deg.y
	rotation_degrees = deg
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
	rotation_degrees = deg

func jumping():
	return jumpCurrTime > 0

func moving():
	var pp = Vector3(position.x, targetPosition.y, position.z)
	return pp.distance_squared_to(targetPosition) > 0.0001

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
	turnEffects.clear()
	battler.advanceSkillConditions()
func endTurn():
	await _updateStatusTurns()
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
	if c == (status.eotInterval-1):
		var action = BattleAction.new()
		action.battler = self
		action.action = status
		action.scope = Global.ETargetScope.ONE
		action.kind = Global.ETargetKind.USER
		action.targetIdx = 0
		action.targets = action.resolveTargets()
		for effect in action.resolveActionList(0):
			await effect.execute(action)

func setAction(action:Resource, kind:Global.ETargetKind, scope:Global.ETargetScope, targetIdx:int):
	currentAction = BattleAction.new()
	currentAction.battler = self
	currentAction.action = action
	currentAction.kind = kind
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
					newAction.kind = counter.action.targetKind
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
		currentAction.kind = Global.ETargetKind.NONE
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
			if b.stateConditionMet(state): ary.append(b)
	return ary

func getAllies(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if !battler.isEnemy(b.battler): 
			if b.cantTarget(): continue
			if b.stateConditionMet(state): ary.append(b)
	return ary

func getAll(state:Global.ETargetState):
	var ary:Array[Battler] = []
	for b in battle.allBattlers:
		if b.cantTarget(): continue
		if b.stateConditionMet(state): ary.append(b)
	return ary

func getLastIndex(tag:StringName):
	return battler.getLastIndex(tag)
func setLastIndex(tag:StringName,value):
	battler.setLastIndex(tag,value)

func stateConditionMet(state:Global.ETargetState):
	return battler.stateConditionMet(state)

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
			eff.setup(graphic)
			await get_tree().process_frame
			graphic.visible = false
			return

func getCurrentPose():
	if overrideState != &"": return overrideState
	return getCurrentState()
func getCurrentState():
	if battler==null: return &"base"
	if battler.isDead():
		return &"dead"
	# Otherwise
	if moving() && _moveSetPose:
		return &"moving"
	# TODO: Set based on current altered status effect
	var _states = battler.getSortedStates()
	for ss in _states:
		var data:Status = Global.Db.getStatus(ss.id)
		if data.statusPose != &"":
			if graphic.spritesheet != null && graphic.spritesheet.collectionDict != null:
				if graphic.spritesheet.collectionDict.has(data.statusPose):
					return data.statusPose
			return &"status"
	if _lowHp:
		return &"lowhp"
	return &"base"

func cantTarget():
	return hidden || !appeared

func isHidden():
	return !appeared || escaped || !graphic.visible

func effectWait():
	return effectWaitTime > 0

func setIsolate(v:bool):
	if v:
		graphic.layers = 524288
	else:
		graphic.layers = 1
	weapon.sprite.layers = graphic.layers
