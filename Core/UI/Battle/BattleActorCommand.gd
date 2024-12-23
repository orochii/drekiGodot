extends Control
class_name BattleActorCommand

const WAIT_OPTIONS = ["◄ Back  ", "◄ Wait ►", "  Forward ►"]

@export var battle:BattleManager
@export var skillSelect:BattleActorSkillSelect
@export var itemSelect:BattleActorItemSelect
@export var targetSelect:BattleActorTargetSelect
@export_group("Members")
@export var highlight:Node3D
@export var highlightParticles:GPUParticles3D
@export var buttons:Array[BaseButton]
@export var waitButton:BaseButton
@export var cursor:AnimatedSprite2D
@export var helpLabel:Label

var waitIdx = 0
var originalButtonPositions:Array[Vector2]
var currentBattler:Battler = null
var readyBattlers:Array[Battler] = []

func _ready():
	visible = false
	battle.onBattlerReady.connect(_onBattlerReady)
	UIUtils.setVNeighbors(buttons)
	for b in buttons:
		originalButtonPositions.append(Vector2(b.offset_left,b.offset_right))
	cursor.play("default")

func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if focused == waitButton: _updateWaitSelection()
	positionCursor(focused)
	if currentBattler != null:
		if _canBeCommanded(currentBattler):
			# Ignore if config is open
			if(battle.configMenu.visible): return
			# Continue action selection
			if visible:
				# Press back to uh switch character (?)
				if Input.is_action_just_pressed("action_cancel"):
					readyBattlers.append(currentBattler)
					_unset()
					return
				# Escape
				if _checkEscapeInput():
					_on_escape_pressed()
		else:
			_unset()
	else:
		# Select a new battler
		if readyBattlers.size() != 0:
			_setup(readyBattlers[0])

func _checkEscapeInput():
	if Input.is_action_just_pressed("cycle_left"):
		return Input.is_action_pressed("cycle_right")
	if Input.is_action_just_pressed("cycle_right"):
		return Input.is_action_pressed("cycle_left")
	return false

func _onBattlerReady(b:Battler):
	if _canBeCommanded(b):
		readyBattlers.append(b)

func _canBeCommanded(b:Battler):
	if(b.currentAction != null): return false
	return b.battler.inputable() && !b.battler.automatic() && !b.escaped

func _setup(b:Battler):
	currentBattler = b
	highlight.global_position = currentBattler.getGlobalHomePosition()
	highlightParticles.emitting = true
	readyBattlers.erase(currentBattler)
	visible = true
	Global.Audio.playSFX("decision")
	selectLast()
	var wIdx = currentBattler.getLastIndex(&"wait")
	if wIdx==null:
		_resetWait()
	else:
		_setWait(wIdx)
func _unset():
	currentBattler = null
	highlightParticles.emitting = false
	visible = false
	skillSelect.close()
	itemSelect.close()
	targetSelect.close()

func selectLast():
	var idx = currentBattler.getLastIndex(&"command")
	if(idx==null): idx = 0
	buttons[idx].grab_focus()

func positionCursor(focused:Node):
	var found = false
	for i in range(buttons.size()):
		var b = buttons[i]
		if(focused == b):
			refreshHelp(i)
			var currPos = Vector2(b.offset_left,b.offset_right)
			var newPos = originalButtonPositions[i] + Vector2(-4,-4)
			var lerpedPos = lerp(currPos, newPos, 0.5)
			b.offset_left = lerpedPos.x
			b.offset_right = lerpedPos.y
			cursor.global_position = b.global_position + Vector2(2,8)
			found = true
			var npr:NinePatchRect = b.get_node("NinePatchRect")
			npr.region_rect.position.x = 16
		else:
			b.offset_left = originalButtonPositions[i].x
			b.offset_right = originalButtonPositions[i].y
			var npr:NinePatchRect = b.get_node("NinePatchRect")
			npr.region_rect.position.x = 0
	cursor.visible = found

func refreshHelp(idx:int):
	helpLabel.text = "actionhelp_%d"%idx

func _on_action_pressed():
	#currentBattler.setWeaponIndex(-1)
	Global.Audio.playSFX("decision")
	currentBattler.setLastIndex(&"command", 0)
	skillSelect.open()

func _on_inventory_pressed():
	currentBattler.setWeaponIndex(-1)
	Global.Audio.playSFX("decision")
	currentBattler.setLastIndex(&"command", 1)
	itemSelect.open()

func _on_wait_pressed():
	Global.Audio.playSFX("decision")
	currentBattler.setWeaponIndex(-1)
	#idx- 0:back 1:wait 2:forward
	currentBattler.setAction(Global.Db.commonActions[waitIdx],Global.ETargetKind.USER,Global.ETargetScope.ONE,0)
	currentBattler.setLastIndex(&"command", 2)
	currentBattler.setLastIndex(&"wait", waitIdx)
	_unset()

func _on_escape_pressed():
	currentBattler.setWeaponIndex(-1)
	currentBattler.setAction(Global.Db.commonActions[3],Global.ETargetKind.USER,Global.ETargetScope.ONE,0)
	_unset()

func _updateWaitSelection():
	if Input.is_action_just_pressed("move_left"):
		waitIdx = clampi(waitIdx + 1, 0, 2)
		_setWait(waitIdx)
	elif Input.is_action_just_pressed("move_right"):
		waitIdx = clampi(waitIdx - 1, 0, 2)
		_setWait(waitIdx)
func _resetWait():
	_setWait(1)
func _setWait(i:int):
	waitIdx = i
	waitButton.get_node("Label").text = WAIT_OPTIONS[i]
