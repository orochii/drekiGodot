extends Node3D
class_name BattleManager

@export var testTroop:EnemyTroop
@export var camera:Camera3D
@export var battlerTemplate:PackedScene
@export var party:Node
@export var troop:Node
@export var partyPositionBase:Vector3 = Vector3(6,0,0)
@export var partyPositionOffset:Vector3 = Vector3(0,0,1)

var allBattlers:Array[Battler]
var waitingBattlers:Array[Battler]
var readyBattlers:Array[Battler]
var actionBattlers:Array[Battler]

func _ready():
	# For playtesting
	if (Global.State.party == null): Global.newGame()
	if (Global.State.currentTroop == null): Global.State.currentTroop = testTroop
	# Play music
	Global.Audio.rememberBGM(&"prebattle")
	_playBattleMusic()
	# Create scenario
	# TODO
	# Create battlers
	_createTroop()
	_createParty()
	# 
	waitingBattlers.append_array(allBattlers)

func _process(delta):
	if(Global.Scene.transitioning): return
	
	# Battle process
	# - Execute actions
	if actionBattlers.size() != 0:
		print("Someone is active! " + actionBattlers[0].battler.getName())
		return
	
	var deltaAtb = Global.Config.battleSpeed * delta
	# Battle process
	# - Advance ATB and get battlers ready!
	var avgSpeed = 0
	for b in allBattlers: avgSpeed += b.battler.getAgi()
	avgSpeed /= allBattlers.size() * 2
	for b in waitingBattlers:
		b.updateAtb(deltaAtb,avgSpeed)
		if(b.isAtbFull()):
			waitingBattlers.erase(b)
			readyBattlers.append(b)
	
	# Battle process
	# - Automatic actions for ready battlers.
	for b in readyBattlers:
		if(b.battler.canAct()):
			if(b.battler.inputable()):
				# Let enemies do their thing
				if(b.battler.automatic()):
					# Pick action
					b.pickAction()
					# Change to next battler array
					readyBattlers.erase(b)
					actionBattlers.append(b)
			else:
				# Ready autoaction
				# Change to next battler array
				pass
		else:
			b.atbValue = 0
			readyBattlers.erase(b)
			waitingBattlers.append(b)
	# Debug
	_doDebug()

#
func _playBattleMusic():
	var currentMusic:SystemAudioEntry = _resolveBattleMusic()
	if currentMusic==null:
		Global.Audio.stopBGM()
	else:
		Global.Audio.playBGM(currentMusic.getStreamName(), currentMusic.volume, currentMusic.pitch)

func _resolveBattleMusic() -> SystemAudioEntry:
	if Global.Audio.audioData.defaultBattleMusic.size() != 0:
		return Global.Audio.audioData.defaultBattleMusic[0]
	if Global.State.currentTroop.battleMusic.size() != 0:
		return Global.State.currentTroop.battleMusic[0]
	return null

func _createParty():
	var members : Array = Global.State.party.members
	var startingPosition = partyPositionBase - (partyPositionOffset * (members.size()-1) / 2)
	for i in range(members.size()):
		var m = members[i]
		var actor = Global.State.getActor(m)
		var inst:Battler = battlerTemplate.instantiate()
		party.add_child(inst)
		inst.battle = self
		inst.setup(actor)
		inst.global_position = startingPosition + (partyPositionOffset * i)
		inst.global_rotation_degrees = Vector3(0, -90, 0)
		allBattlers.append(inst)

func _createTroop():
	var _troopData:EnemyTroop = Global.State.currentTroop
	if(_troopData == null): return
	
	for entry in _troopData.entries:
		entry.position
		var enemy = GameEnemy.new(entry.enemy.getId())
		var inst:Battler = battlerTemplate.instantiate()
		troop.add_child(inst)
		inst.battle = self
		inst.setup(enemy)
		inst.global_position = entry.position
		inst.global_rotation_degrees = Vector3(0, 90, 0)
		allBattlers.append(inst)

func _doDebug():
	if(Input.is_action_just_pressed("action_cancel")):
		print("END?")
		Global.Audio.restoreBGM(&"prebattle")
		Global.Scene.endBattle()
