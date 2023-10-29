extends Object
class_name BattleAction

var battler:Battler
var action:Resource #(BaseSkill or BaseItem)
var scope:Global.ETargetScope
var targetIdx:int

func selectRandomTarget():
	var targetKind = Global.ETargetKind.ENEMY
	var targetState = Global.ETargetState.ALIVE
	if action is UseableSkill:
		var sk = action as UseableSkill
		targetKind = sk.targetKind
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetKind = it.targetKind
		targetState = it.targetState
	var ary = getTargetArray(targetKind,targetState)
	targetIdx = randi() % ary.size()

func resolveTargets():
	var targetKind = Global.ETargetKind.ENEMY
	var targetState = Global.ETargetState.ALIVE
	if action is UseableSkill:
		var sk = action as UseableSkill
		targetKind = sk.targetKind
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetKind = it.targetKind
		targetState = it.targetState
	var ary = getTargetArray(targetKind,targetState)
	match scope:
		Global.ETargetScope.ALL:
			return ary
		Global.ETargetScope.ONE:
			return [ary[targetIdx]]
		_:
			var rndIdx = randi() % ary.size()
			return [ary[rndIdx]]

func getTargetArray(kind:Global.ETargetKind,state:Global.ETargetState):
	match kind:
		Global.ETargetKind.ALLY:
			return battler.getAllies(state)
		Global.ETargetKind.ANY:
			return battler.getAll(state)
		_:
			return battler.getEnemies(state)
