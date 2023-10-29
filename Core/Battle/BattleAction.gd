extends Object
class_name BattleAction

var battler:Battler
var action:Resource #(BaseSkill or BaseItem)
var scope:Global.ETargetScope
var targetIdx:int
var repeatIdx:int = 0
var remainingTimes:int = 0

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
	var ary = _getTargetArray(targetKind,targetState)
	targetIdx = randi() % ary.size()

func setRepeats():
	remainingTimes = resolveRepeats()
	repeatIdx = 0
func repeatAvailable():
	return repeatIdx <= remainingTimes;
func advanceRepeat():
	repeatIdx += 1
func resolveRepeats() -> int: 
	if action is UseableSkill:
		var sk = action as UseableSkill
		return sk.repeats
	return 0

func resolveActionList(type:int) -> Array[BaseEffect]:
	if action is UseableSkill:
		var sk = action as UseableSkill
		match type:
			0:
				return sk.startSequence
			1:
				return sk.actionSequence
			2:
				return sk.endSequence
	elif action is UseableItem:
		var it = action as UseableItem
		match type:
			0:
				return it.startSequence
			1:
				return it.actionSequence
			2:
				return it.endSequence
	return []

func resolveTargets() -> Array[Battler]:
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
	var ary = _getTargetArray(targetKind,targetState)
	match scope:
		Global.ETargetScope.ALL:
			return ary
		Global.ETargetScope.ONE:
			return [ary[targetIdx]]
		_:
			var rndIdx = randi() % ary.size()
			return [ary[rndIdx]]

func _getTargetArray(kind:Global.ETargetKind,state:Global.ETargetState):
	# Invert kind if is i.e. confused
	if battler.battler.hasRestriction(Global.ERestriction.AttackAlly):
		match kind:
			Global.ETargetKind.ALLY:
				kind = Global.ETargetKind.ENEMY
			Global.ETargetKind.ANY:
				kind = Global.ETargetKind.ALLY
			_:
				kind = Global.ETargetKind.ALLY
	# Return the array of viable targets
	match kind:
		Global.ETargetKind.ALLY:
			return battler.getAllies(state)
		Global.ETargetKind.ANY:
			return battler.getAll(state)
		_:
			return battler.getEnemies(state)
