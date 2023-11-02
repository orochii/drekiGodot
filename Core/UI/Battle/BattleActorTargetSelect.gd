extends Control
class_name BattleActorTargetSelect

const DIR_COOLDOWN = 0.2

@export var actorCommand:BattleActorCommand
@export_group("Members")
@export var cursor:AnimatedSprite2D
@export var selector:Node3D
@export var selectorParticles:GPUParticles3D

var _dirCooldown:float = 0

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
	elif obj is UseableSkill:
		_skill = obj as UseableSkill
		_action.scope = _skill.targetScope
		_state = _skill.targetState
	else:
		return
	_selectTarget(0)
	actorCommand.skillSelect.close()
	visible = true

func select():
	Global.Audio.playSFX("decision")
	_action.targetIdx = _getTargets().find(_currentTarget)
	_action.battler.currentAction = _action
	_action = null
	_currentTarget = null
	actorCommand._unset()

func goBack():
	Global.Audio.playSFX("cancel")
	actorCommand.skillSelect.open()

func close():
	visible = false
	selectorParticles.emitting = false

func _ready():
	cursor.play(&"default")
	visible = false

func _process(delta):
	if(!visible): return
	# If current target is invalid
	if _currentTarget != null:
		if _isCurrentTargetValid()==false:
			_selectTarget(0)
	# Cancel
	if Input.is_action_just_pressed("action_cancel"):
		goBack()
		return
	# Select
	if Input.is_action_just_pressed("action_ok"):
		select()
		return
	# Move cursor
	var dir = Input.get_vector("move_left","move_right","move_down","move_up")
	if dir != Vector2.ZERO:
		if _dirCooldown <= 0:
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
		print(_targets)
		var _pos = _currentTarget.homePosition
		var _targetPos = Vector2(_pos.x, _pos.z) + dir
		var _closestTarget = null
		var _closestDistance = 0
		for t in _targets:
			if t != _currentTarget:
				var home = t.homePosition
				var p = Vector2(home.x, home.z)
				var d = p.distance_squared_to(_targetPos)
				if _closestTarget==null || _closestDistance > d:
					_closestTarget = t
					_closestDistance = d
		if _closestTarget != null:
			Global.Audio.playSFX("cursor")
			_currentTarget = _closestTarget
			_refreshTarget()

func _getTargets():
	if _item != null:
		return _action._getTargetArray(_item.targetKind,_state)
	elif _skill != null:
		return _action._getTargetArray(_skill.targetKind,_state)
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
	else:
		cursor.visible = true
		selector.global_position = _currentTarget.homePosition
		selectorParticles.emitting = true
		var pos = actorCommand.battle.posToScreen(_currentTarget.homePosition)
		pos.x = roundi(pos.x)
		pos.y = roundi(pos.y) - _currentTarget.getScreenSize().y
		cursor.position = pos

func _isCurrentTargetValid():
	if _currentTarget == null: return false
	if _state==Global.ETargetState.ANY: return true
	return _currentTarget.battler.isDead() == (_state==Global.ETargetState.DEAD)
