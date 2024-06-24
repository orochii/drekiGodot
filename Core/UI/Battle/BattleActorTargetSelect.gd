extends Control
class_name BattleActorTargetSelect

const DIR_COOLDOWN = 0.2
const PRINT_DEBUG = false

@export var actorCommand:BattleActorCommand
@export_group("Members")
@export var scopeLabel:Label
@export var status:BattleTargetInfoWindow
@export var cursor:AnimatedSprite2D
@export var selector:Node3D
@export var selectorParticles:GPUParticles3D
@export var selectorParticlesMulti:GPUParticles3D

var _dirCooldown:float = 0
var _lastDir:Vector2
var _canChangeScope = false

var _action:BattleAction
var _currentTarget:Battler
var _item:UseableItem
var _skill:UseableSkill
var _state:Global.ETargetState
var _currentScope:Global.ETargetScope = Global.ETargetScope.ONE

func setup(obj:Resource):
	_canChangeScope = false
	_action = BattleAction.new()
	_action.battler = actorCommand.currentBattler
	_action.action = obj
	_item = null
	_skill = null
	if obj is UseableItem:
		_item = obj as UseableItem
		_action.kind = _item.targetKind
		_action.scope = _item.targetScope
		_currentScope = _action.scope
		_state = _item.targetState
		if _item.targetKind == Global.ETargetKind.NONE:
			select()
			return
		elif _item.targetKind == Global.ETargetKind.ALLY:
			_state = Global.ETargetState.ANY
	elif obj is UseableSkill:
		_skill = obj as UseableSkill
		_action.kind = _skill.targetKind
		_action.scope = _skill.targetScope
		_currentScope = _action.scope
		_canChangeScope = _skill.targetCanChangeScope
		_state = _skill.targetState
		if _skill.targetKind == Global.ETargetKind.NONE:
			select()
			return
		elif _skill.targetKind == Global.ETargetKind.ALLY:
			_state = Global.ETargetState.ANY
	else:
		return
	_selectTarget(0)
	actorCommand.skillSelect.close()
	actorCommand.itemSelect.close()
	visible = true

func select():
	if _currentScope == Global.ETargetScope.ALL:
		match _action.kind:
			Global.ETargetKind.ALLY:
				if _action.battler.battler.isEnemy(_currentTarget.battler):
					_action.kind = Global.ETargetKind.ENEMY
			Global.ETargetKind.ENEMY:
				if !_action.battler.battler.isEnemy(_currentTarget.battler):
					_action.kind = Global.ETargetKind.ALLY
		pass
	_action.scope = _currentScope
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
	selectorParticlesMulti.emitting = false

func _ready():
	cursor.play(&"default")
	visible = false

func _process(delta):
	if(!visible): return
	if actorCommand.battle.configMenu.visible: return
	#
	match _currentScope:
		Global.ETargetScope.ONE:
			scopeLabel.text = "ONE"
		Global.ETargetScope.ALL:
			scopeLabel.text = "ALL"
		Global.ETargetScope.RANDOM:
			scopeLabel.text = "RANDOM"
	# Can pay cost?
	if !_action.battler.battler.canUse(_action.action):
		goBack()
		return
	# If current target is invalid
	if _currentTarget != null:
		if _isCurrentTargetValid()==false:
			_selectTarget(0)
			return
		else:
			repositionCursor()
	# Change scope
	if _canChangeScope:
		if Input.is_action_just_pressed("cycle_left") || Input.is_action_just_pressed("cycle_right"):
			match _currentScope:
				Global.ETargetScope.ALL:
					_currentScope = Global.ETargetScope.ONE
				Global.ETargetScope.ONE:
					_currentScope = Global.ETargetScope.ALL
			selectorParticlesMulti.emitting = selectorParticles.emitting &&_currentScope==Global.ETargetScope.ALL
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
			_lastDir = dir
		else:
			_dirCooldown -= delta
	else:
		_dirCooldown = 0

func _moveCursor(dir:Vector2):
	if _currentTarget==null:
		_selectTarget(0)
	else:
		var _targets = _getTargets()
		var _pos = _currentTarget.getGlobalHomePosition()
		var _pos2d = actorCommand.battle.posToScreen(_pos)
		var _targetPos = (_pos2d + dir)
		var maxDiff = deg_to_rad(85)
		var _angle = dir.angle()
		var _closestTarget = null
		var _closestDistance = 0
		var _closestAngle = 0
		if(PRINT_DEBUG): print_rich("_pos2d:[color=green](x%f y%f)[/color]"%[_pos2d.x, _pos2d.y])
		if(PRINT_DEBUG): print_rich("dir:[color=green](x%f y%f)[/color] _angle:[color=green]%f[/color]" % [dir.x, dir.y, rad_to_deg(_angle)])
		for t in _targets:
			if t != _currentTarget:
				var home = t.getGlobalHomePosition()
				var p = actorCommand.battle.posToScreen(home)
				var d = p.distance_squared_to(_targetPos)
				var a = (p-_pos2d).angle()
				var diffA = abs(angle_difference(_angle, a))
				if(PRINT_DEBUG): print_rich("t:[color=red]%s[/color] p:[color=green](x%f y%f)[/color] a:[color=green]%f[/color] || diffA:%f" % [t.battler.getName(), p.x, p.y, rad_to_deg(a),rad_to_deg(diffA)])
				if diffA<maxDiff && (_closestTarget==null || _closestDistance > d):
					_closestTarget = t
					_closestDistance = d
					maxDiff = diffA
		if _closestTarget != null:
			Global.Audio.playSFX("cursor")
			_currentTarget = _closestTarget
			_refreshTarget()

func _getTargets():
	if _item != null:
		return _action.getTargetArray(_state)
	elif _skill != null:
		return _action.getTargetArray(_state)
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
		selectorParticlesMulti.emitting = false
		status.setup(null)
	else:
		cursor.visible = true
		selector.global_position = _currentTarget.getGlobalHomePosition()
		selectorParticles.emitting = true
		selectorParticlesMulti.emitting = selectorParticles.emitting &&_currentScope==Global.ETargetScope.ALL
		repositionCursor()
		status.setup(_currentTarget)

func repositionCursor():
	var pos = actorCommand.battle.posToScreen(_currentTarget.getGlobalHomePosition()) #getGlobalHomePosition()
	pos.x = roundi(pos.x)
	pos.y = roundi(pos.y) - _currentTarget.getScreenSize().y
	pos.y = maxi(pos.y, 16)
	cursor.position = pos

func _isCurrentTargetValid():
	if _currentTarget == null: return false
	if _state==Global.ETargetState.ANY: return true
	if _action.kind==Global.ETargetKind.ALLY: return true
	return _currentTarget.battler.isDead() == (_state==Global.ETargetState.DEAD)
