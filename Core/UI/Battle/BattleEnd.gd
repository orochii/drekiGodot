extends Control
class_name BattleEnd

@export var battle:BattleManager
@export var party:BattlePartyResultWindow
@export var spoils:BattleSpoilsWindow
var test = false
var waitTime:float = 0
var currScreen = 0

func execute(result):
	if result == BattleManager.EBattleResult.LOSE:
		endBattle()
	else:
		var defeatedEnemies:Array[GameEnemy] = []
		var exp = 0
		var app = 0
		var gold = 0
		var treasures:Array[BaseItem] = []
		var battleBonuses = {&"global" : [&"noQuarter"]}
		var maxEnemyLevel = 0
		for b in battle.allBattlers:
			if b.battler is GameEnemy:
				var enemy = b.battler as GameEnemy
				if b.battler.isDead(): 
					var data:Enemy = enemy.getData()
					if b.turn != 0: battleBonuses[&"global"].erase(&"noQuarter")
					defeatedEnemies.append(b.battler)
					maxEnemyLevel = max(maxEnemyLevel,b.battler.level)
					# TODO: register enemy
					exp += data.rewardExp
					app += data.rewardApp
					gold+= data.rewardGold
					for treasure in data.rewardTreasure:
						var r = randf()
						if r < treasure.rate:
							treasures.append(treasure.item)
		# Ignore battle end if there's no gains
		if (exp == 0 && app == 0 && gold == 0 && treasures.size() == 0):
			endBattle()
			return
		# Count escaped characters
		var hiddenMult = 1.0
		var totalActorTurns = 0
		var escapedAllies = []
		for b in battle.partyBattlers:
			if b.battler is GameActor:
				var actor = b.battler as GameActor
				if b.escaped:
					escapedAllies.append(b.battler)
					hiddenMult += 0.25
				totalActorTurns += b.turn
		# Iterate through party members
		var partyData = []
		var members : Array = Global.State.party.getMembers()
		for i in range(members.size()):
			battleBonuses[i] = []
			var m = members[i]
			var actor = Global.State.getActor(m)
			var gainExp = 0
			var gainAp = 0
			if actor.canGetExp():
				var battler = battle.findPartyBattler(actor)
				var hiddenTotal = 0.5 if escapedAllies.has(actor) else hiddenMult
				var extraMult = 0
				if escapedAllies.has(actor): # Escaped
					battleBonuses[i].append(&"escaped")
				else:
					# Lurker check
					if battler.turn < 1:
						extraMult -= 0.1
						battleBonuses[i].append(&"lurker")
					# Nuke check
					if battler.turn == 1 && totalActorTurns==1 && battle.troopBattlers.size() > 1:
						extraMult += 0.1
						battleBonuses[i].append(&"nuke")
					# Lone Wolf
					if (hiddenTotal > 1):
						# Multiplier applied to hidden multiplier
						battleBonuses[i].append(&"loneWolf")
					# Overpower
					if maxEnemyLevel < actor.level:
						var lvlDiff = (actor.level - maxEnemyLevel) / 5
						if lvlDiff != 0:
							var lvlMult = min((0.1 * lvlDiff), 0.5)
							extraMult -= lvlMult
							battleBonuses[i].append(&"overpower")
					elif maxEnemyLevel > actor.level:
						var lvlDiff = (maxEnemyLevel - actor.level) / 5
						if lvlDiff != 0:
							var lvlMult = min((0.2 * lvlDiff), 1.0)
							extraMult += lvlMult
							battleBonuses[i].append(&"valiant")
				# Apply multipliers to exp
				var totalMult = hiddenTotal + extraMult
				gainExp = roundi(exp * totalMult)
				gainAp = roundi(app * totalMult)
				# TODO: Fylgja stuff
			var entry = {
				"actor" : actor,
				"exp" : gainExp,
				"ap" : gainAp
			}
			partyData.append(entry)
		# Update UI
		party.setup(partyData)
		spoils.setup(treasures)
		# Apply stuff
		_applyParty(partyData)
		_applyTreasure(treasures)
		_applyGold(gold)
		# Eeee
		visible = true
		waitTime = 1

func _ready():
	visible = false

func _process(delta):
	if(!visible): return
	if(Global.Scene.transitioning): return
	if waitTime > 0:
		waitTime -= delta
		if waitTime<=0:
			_next()
		return
	#
	if Input.is_action_just_pressed("action_ok"):
		_next()

func _applyParty(data):
	for entry in data:
		# entry(actor,exp,ap)
		var actor:GameActor = entry["actor"]
		actor.gainExp(entry["exp"])
		actor.gainApp(entry["ap"])

func _applyTreasure(items:Array[BaseItem]):
	for i in items:
		Global.State.party.gainItem(i.getId(), 1)

func _applyGold(gold):
	Global.State.bank.addGold(gold)

func _next():
	Global.Scene.performTransition()
	currScreen += 1
	match currScreen:
		1: # Result Party
			party.visible = true
			spoils.visible = false
		2: # Result Treasure
			party.visible = false
			spoils.visible = true
			spoils.selectFirst()
		3: # End
			endBattle()

func endBattle():
	# restore party's cooldowns
	var members = Global.State.party.getMembers()
	for m in members:
		var actor = Global.State.getActor(m)
		actor.resetSkillCooldowns()
	# Restore BGM, exit from battle
	Global.Audio.restoreBGM(&"prebattle")
	Global.Scene.endBattle()
	if(test): Global.Scene.quit()
