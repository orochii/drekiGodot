extends Control
class_name BattleActorCommand

@export var battle:BattleManager

var currentBattler:Battler = null
var readyBattlers:Array[Battler] = []

func _ready():
	visible = false
	battle.onBattlerReady.connect(_onBattlerReady)

func _process(delta):
	if currentBattler != null:
		if canBeCommanded(currentBattler):
			# Continue action selection
			if visible:
				# Press back to uh switch character (?)
				if Input.is_action_just_pressed("action_cancel"):
					readyBattlers.append(currentBattler)
					currentBattler = null
					visible = false
		else:
			currentBattler = null
			visible = false
	else:
		# Select a new battler
		if readyBattlers.size() != 0:
			currentBattler = readyBattlers[0]
			readyBattlers.erase(currentBattler)
			print("%s set to command." % currentBattler.battler.getName())
			visible = true
			Global.Audio.playSFX("decision")

func _onBattlerReady(b:Battler):
	if canBeCommanded(b):
		print("%s is ready." % b.battler.getName())
		readyBattlers.append(b)

func canBeCommanded(b:Battler):
	return b.battler.inputable() && !b.battler.automatic()
