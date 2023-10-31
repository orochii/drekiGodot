extends Control
class_name BattleActorCommand

const WAIT_OPTIONS = ["◄ Back  ", "◄ Wait ►", "  Forward ►"]

@export var battle:BattleManager
@export var buttons:Array[BaseButton]
@export var waitButton:BaseButton
@export var cursor:AnimatedSprite2D

var waitIdx = 0
var originalButtonPositions:Array[Vector2]
var currentBattler:Battler = null
var readyBattlers:Array[Battler] = []

func _ready():
	visible = false
	battle.onBattlerReady.connect(_onBattlerReady)
	UIUtils.setVNeighbors(buttons)
	for b in buttons: originalButtonPositions.append(b.position)
	cursor.play("default")

func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if focused == waitButton: _updateWaitSelection()
	positionCursor(focused)
	if currentBattler != null:
		if _canBeCommanded(currentBattler):
			# Continue action selection
			if visible:
				# Press back to uh switch character (?)
				if Input.is_action_just_pressed("action_cancel"):
					readyBattlers.append(currentBattler)
					_unset()
		else:
			_unset()
	else:
		# Select a new battler
		if readyBattlers.size() != 0:
			_setup(readyBattlers[0])

func _onBattlerReady(b:Battler):
	if _canBeCommanded(b):
		print("%s is ready." % b.battler.getName())
		readyBattlers.append(b)

func _canBeCommanded(b:Battler):
	return b.battler.inputable() && !b.battler.automatic()

func _setup(b:Battler):
	currentBattler = b
	readyBattlers.erase(currentBattler)
	print("%s set to command." % currentBattler.battler.getName())
	visible = true
	Global.Audio.playSFX("decision")
	buttons[0].grab_focus()
	_resetWait()
func _unset():
	currentBattler = null
	visible = false

func positionCursor(focused:Node):
	var found = false
	for i in range(buttons.size()):
		var b = buttons[i]
		if(focused == b):
			var newPos = originalButtonPositions[i] + Vector2(-4,0)
			b.position = lerp(b.position, newPos, 0.5)
			cursor.global_position = b.global_position + Vector2(2,8)
			found = true
			var npr:NinePatchRect = b.get_node("NinePatchRect")
			npr.region_rect.position.x = 16
		else:
			b.position = originalButtonPositions[i]
			var npr:NinePatchRect = b.get_node("NinePatchRect")
			npr.region_rect.position.x = 0
	cursor.visible = found

func _on_action_pressed():
	Global.Audio.playSFX("decision")

func _on_inventory_pressed():
	Global.Audio.playSFX("decision")

func _on_wait_pressed():
	Global.Audio.playSFX("decision")
	#idx- 0:back 1:wait 2:forward
	currentBattler.setAction(Global.Db.commonActions[waitIdx],Global.ETargetScope.ONE,0)
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
