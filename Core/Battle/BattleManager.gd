extends Node3D
class_name BattleManager

enum EBattleResult {
	NONE, WIN, LOSE, DRAW
}
const START_DELAY = 1.5

signal onBattlerReady(battler:Battler)

@export var testTroop:EnemyTroop
@export var camera:Camera3D
@export var battlerTemplate:PackedScene
@export var party:Node
@export var troop:Node
@export var partyPositionBase:Vector3 = Vector3(6,0,0)
@export var partyPositionOffset:Vector3 = Vector3(0,0,1)
@export var partyStatus:BattlePartyStatus
@export var battlerStatus:BattlerStatusManager
@export var actorCommand:BattleActorCommand
@export var damagePopupTemplate:PackedScene
@export var damagePopupContainer:Control
@export var configMenu:ConfigMenu
@export var battleEndWindow:BattleEnd

var _start = false
var battleResult:EBattleResult = EBattleResult.NONE
var waitingCount:float = 0.0
#
var partyBattlers:Array[Battler]
var troopBattlers:Array[Battler]
#
var allBattlers:Array[Battler]
var waitingBattlers:Array[Battler]
var readyBattlers:Array[Battler]
var actionBattlers:Array[Battler]

func battlerEscape(b:Battler):
	b.goToStartPosition()
	allBattlers.erase(b)
	waitingBattlers.erase(b)
	readyBattlers.erase(b)
	actionBattlers.erase(b)

func endBattlerTurn(b:Battler):
	await b.endTurn()
	readyBattlers.erase(b)
	actionBattlers.erase(b)
	waitingBattlers.append(b)

func battleEnd(result:EBattleResult):
	battleResult = result
	battleEndWindow.execute(result)

func spawnDamagePop(b:Battler,eff:Dictionary):
	var pop = damagePopupTemplate.instantiate()
	pop.setup(b,eff)
	damagePopupContainer.add_child(pop)

func findPartyBattler(actor):
	for b in partyBattlers:
		if b.battler == actor: return b
	return null

func posToScreen(pos : Vector3) -> Vector2:
	return camera.unproject_position(pos)

func screenSize() -> Vector2:
	return get_viewport().get_visible_rect().size

func _ready():
	# For playtesting
	if (Global.State.party == null):
		_prepareTest()
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
	# Add a small wait to the start
	if(Global.Scene.transitioning):
		waitingCount = START_DELAY

func _process(delta):
	# Wait
	if(waitingCount > 0):
		waitingCount -= delta
		return
	if !_start:
		for b in allBattlers:
			if b.appeared: b.goToHome()
		_start = true
	# Stop conditions
	if(Global.Scene.transitioning): return
	if(battleResult != EBattleResult.NONE): return
	if(configMenu.visible): return
	# Debug
	if _doInput():
		return
	
	# Judge
	if _judge():
		return
	
	# Battle process
	# - Execute actions
	if actionBattlers.size() != 0:
		# TODO Action execution
		var currentAction:BattleAction = actionBattlers[0].currentAction
		await _executeAction(currentAction)
		return
	
	# Battle process
	# - Advance ATB and get battlers ready!
	if _canAdvanceAtb():
		var deltaAtb = _calcDeltaAtb(delta)
		var avgSpeed = _calcAvgSpeed()
		for b in waitingBattlers:
			await _advanceAtb(b,deltaAtb,avgSpeed)
	
	# Battle process
	# - Automatic actions for ready battlers.
	for b in readyBattlers:
		await _advanceActions(b)

func _judge():
	var alliesAlive:int = 0
	var totalAllies:int = 0
	var enemiesAlive:int = 0
	for b in allBattlers:
		if !b.appeared: continue
		if b.battler is GameActor:
			totalAllies += 1
			if !b.battler.isDead(): alliesAlive += 1
		else:
			if !b.battler.isDead(): enemiesAlive += 1
	# Debug
	#EBattleResult.DRAW
	if totalAllies==0:
		battleEnd(EBattleResult.DRAW)
		return true
	#EBattleResult.LOSE
	if alliesAlive==0:
		battleEnd(EBattleResult.LOSE)
		return true
	#EBattleResult.WIN
	if enemiesAlive==0:
		battleEnd(EBattleResult.WIN)
		return true
	return false

func _canAdvanceAtb():
	return Global.Config.activeBattle || actorCommand.currentBattler == null

func _calcDeltaAtb(delta):
	return Global.Config.battleSpeed * delta / 10.0

func _calcAvgSpeed():
	var avgSpeed = 0
	for b in allBattlers: avgSpeed += b.battler.getAgi()
	avgSpeed /= allBattlers.size() * 2
	return avgSpeed

func _advanceAtb(b:Battler,deltaAtb,avgSpeed):
	await b.updateAtb(deltaAtb,avgSpeed)
	await _waitForEffects([b])
	if(b.isAtbFull()):
		await b.startTurn()
		await _waitForEffects([b])
		waitingBattlers.erase(b)
		readyBattlers.append(b)
		onBattlerReady.emit(b)

func _advanceActions(b:Battler):
	if(b.battler.canAct()):
		if(b.battler.inputable()):
			# Let enemies do their thing
			if(b.battler.automatic()):
				# Pick action
				b.pickAction()
		else:
			# Ready autoaction
			b.pickAutoaction()
		if(b.currentAction != null):
			# Change to next battler array
			readyBattlers.erase(b)
			actionBattlers.append(b)
	else:
		b.atbValue = 0
		await endBattlerTurn(b)

func _executeAction(currentAction:BattleAction):
	if currentAction==null: return
	var activeBattler = currentAction.battler
	activeBattler.currentAction = null
	if currentAction.action != null:
		# Resolve action cost
		currentAction.resolveCost()
		currentAction.battler.cacheDirection()
		# Resolve initial targets
		currentAction.targets = currentAction.resolveTargets()
		currentAction.battler.lookAtTargets(currentAction.targets)
		# Resolve starting effects
		var startEffects:Array[BaseEffect] = currentAction.resolveActionList(0)
		for effect in startEffects:
			await effect.execute(currentAction)
		# Resolve action effects N times
		currentAction.setRepeats()
		while currentAction.repeatAvailable():
			var effects:Array[BaseEffect] = currentAction.resolveActionList(1)
			for effect in effects:
				await effect.execute(currentAction)
				# Check for follow-up attacks
				for b in allBattlers:
					b.checkCounter(activeBattler,effect,currentAction.targets)
			currentAction.advanceRepeat()
			# Refresh targets
			await _waitForEffects(currentAction.targets)
			if currentAction.repeatAvailable():
				currentAction.targets = currentAction.resolveTargets()
				currentAction.battler.lookAtTargets(currentAction.targets)
		
		# Resolve counter/follow-up actions
		for b in allBattlers:
			for counterAction in b.currentCounterAction:
				currentAction.battler.cacheDirection()
				counterAction.setRepeats()
				while counterAction.repeatAvailable():
					var effects:Array[BaseEffect] = counterAction.resolveActionList(1)
					for effect in effects:
						await effect.execute(counterAction)
					counterAction.advanceRepeat()
					# Refresh targets
					await _waitForEffects(counterAction.targets)
					counterAction.targets = counterAction.resolveTargets()
					counterAction.battler.lookAtTargets(counterAction.targets)
				if counterAction.anyAllyOnTargets():
					counterAction.battler.resetDirection()
			b.clearCounters()
		
		# resolve ending effects
		var endEffects:Array[BaseEffect] = currentAction.resolveActionList(2)
		for effect in endEffects:
			await effect.execute(currentAction)
		if !currentAction.battler.escaped:
			if currentAction.anyAllyOnTargets():
				currentAction.battler.resetDirection()
			currentAction.battler.goToHome()
	else:
		pass
	await endBattlerTurn(activeBattler)

func _waitForEffects(targets):
	for t in targets:
		if t.battler.isDead():
			t.collapse()
		else:
			t.getUp()
		while t.effectWait():
			await get_tree().process_frame

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
		inst.setStartDirection(-90)
		inst.setHomePosition(startingPosition + (partyPositionOffset * i))
		inst.moveToStartPosition()
		allBattlers.append(inst)
		partyBattlers.append(inst)
		partyStatus.setup(inst)
		battlerStatus.setup(inst,false)

func _createTroop():
	var _troopData:EnemyTroop = Global.State.currentTroop
	if(_troopData == null): return
	
	for entry in _troopData.entries:
		entry.position
		var enemy = GameEnemy.new(entry.enemy.getId())
		var inst:Battler = battlerTemplate.instantiate()
		troop.add_child(inst)
		inst.battle = self
		inst.appeared = (entry.flags & 1) == 0
		inst.setup(enemy)
		inst.setStartDirection(90)
		inst.setHomePosition(entry.position)
		inst.moveToStartPosition()
		allBattlers.append(inst)
		troopBattlers.append(inst)
		battlerStatus.setup(inst,true)

func _doInput() -> bool:
	# Summon config
	if(Input.is_action_just_pressed("sys_config")):
		Global.Audio.playSFX("decision")
		configMenu.open(false)
		return true
	# Debug end battle
	#if(Input.is_action_just_pressed("action_extra")):
	#	battleEnd(EBattleResult.DRAW)
	#	return true
	return false

func _prepareTest():
	battleEndWindow.test = true
	Global.newGame()
	# Give all items?
	var path = "res://Data/Items/"
	var pathLen = path.length()
	var allItems = Global.get_dir_contents(path)
	for i in allItems[0]:
		var s = i as String
		var idLen = s.length() - pathLen - 5
		var itemId = s.substr(pathLen, idLen)
		Global.State.party.gainItem(itemId,GameParty.MAX_ITEMS)
