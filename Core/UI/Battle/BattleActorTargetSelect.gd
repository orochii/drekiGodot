extends Control
class_name BattleActorTargetSelect

const DIR_COOLDOWN = 0.2

@export var actorCommand:BattleActorCommand
@export_group("Members")
@export var status:BattleTargetInfoWindow
@export var cursor:AnimatedSprite2D
@export var selector:Node3D
@export var selectorParticles:GPUParticles3D

var _dirCooldown:float = 0
var _lastDir:Vector2

var _action:BattleAction
var _currentTarget:Battler
var _item:UseableItem
var _skill:UseableSkill
var _state:Global.ETargetState

func setup(obj:Resource):
	_action = BattleAction.new()
	_action.battler = actorCommand.currentBattler
	_action.action = obj
	_item = null
	_skill = null
	if obj is UseableItem:
		_item = obj as UseableItem
		_action.scope = _item.targetScope
		_state = _item.targetState
		if _item.targetKind == Global.ETargetKind.NONE:
			select()
			return
	elif obj is UseableSkill:
		_skill = obj as UseableSkill
		_action.scope = _skill.targetScope
		_state = _skill.targetState
		if _skill.targetKind == Global.ETargetKind.NONE:
			select()
			return
	else:
		return
	_selectTarget(0)
	actorCommand.skillSelect.close()
	actorCommand.itemSelect.close()
	visible = true

func select():
	_action.targetIdx = _getTargets().find(_currentTarget)
	_action.battler.currentAction = _action
	_action = null
	_currentTarget = null
	actorCommand._unset()

func goBack():
	if _skill != null:
		actorCommand.skillSelect.open()
	if _item != null:
		actorCommand.itemSelect.open()
	close()

func close():
	visible = false
	selectorParticles.emitting = false

func _ready():
	cursor.play(&"default")
	visible = false

func _process(delta):
	if(!visible): return
	# Can pay cost?
	if !_action.battler.battler.canUse(_action.action):
		goBack()
		return
	# If current target is invalid
	if _currentTarget != null:
		if _isCurrentTargetValid()==false:
			_selectTarget(0)
	# Cancel
	if Input.is_action_just_pressed("action_cancel"):
		Global.Audio.playSFX("cancel")
		goBack()
		return
	# Select
	if Input.is_action_just_pressed("action_ok"):
		Global.Audio.playSFX("decision")
		select()
		return
	# Move cursor
	var dir = Input.get_vector("move_left","move_right","move_up","move_down")
	if dir != Vector2.ZERO:
		if _dirCooldown <= 0 || _lastDir != dir:
			_dirCooldown = DIR_COOLDOWN
			_moveCursor(dir)
		else:
			_dirCooldown -= delta
	else:
		_dirCooldown = 0

func _moveCursor(dir:Vector2):
	if _currentTarget==null:
		_selectTarget(0)
	else:
		var _targets = _getTargets()
		var _pos = _currentTarget.homePosition
		var _pos2d = Vector2(_pos.x, _pos.z)
		var _targetPos = _pos2d + dir
		var maxDiff = deg_to_rad(45)
		var _angle = dir.angle()
		var _closestTarget = null
		var _closestDistance = 0
		var _closestAngle = 0
		for t in _targets:
			if t != _currentTarget:
				var home = t.homePosition
				var p = Vector2(home.x, home.z)
				var d = p.distance_squared_to(_targetPos)
				var a = (p-_pos2d).angle()
				var diffA = abs(_angle-a)
				if diffA<maxDiff && (_closestTarget==null || _closestDistance > d):
					_closestTarget = t
					_closestDistance = d
		if _closestTarget != null:
			Global.Audio.playSFX("cursor")
			_currentTarget = _closestTarget
			_refreshTarget()

func _getTargets():
	if _item != null:
		return _action.getTargetArray(_item.targetKind,_state)
	elif _skill != null:
		return _action.getTargetArray(_skill.targetKind,_state)
	else:
		return []

func _selectTarget(idx:int):
	var _targets = _getTargets()
	if idx < 0:
		idx = 0
	elif idx >= _targets.size():
		idx = _targets.size() - 1
	_action.targetIdx = idx
	if _action.targetIdx >= 0 && _action.targetIdx < _targets.size():
		_currentTarget = _targets[_action.targetIdx]
	else:
		_currentTarget = null
	_refreshTarget()

func _refreshTarget():
	if _currentTarget==null:
		cursor.visible = false
		selectorParticles.emitting = false
		status.setup(null)
	else:
		cursor.visible = true
		selector.global_position = _currentTarget.homePosition + Vector3(0,0,-0.3)
		selectorParticles.emitting = true
		var pos = actorCommand.battle.posToScreen(_currentTarget.homePosition)
		pos.x = roundi(pos.x)
		pos.y = roundi(pos.y) - _currentTarget.getScreenSize().y
		pos.y = maxi(pos.y, 16)
		cursor.position = pos
		status.setup(_currentTarget)

func _isCurrentTargetValid():
	if _currentTarget == null: return false
	if _state==Global.ETargetState.ANY: return true
	return _currentTarget.battler.isDead() == (_state==Global.ETargetState.DEAD)
