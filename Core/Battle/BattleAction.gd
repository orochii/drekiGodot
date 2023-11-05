extends Object
class_name BattleAction

var battler:Battler
var action:Resource #(Status, BaseSkill or BaseItem)
var scope:Global.ETargetScope
var targetIdx:int
# This must be set by the effects themselves, which sounds terrible
var targets:Array[Battler]=[]

# Don't set manually (except for maybe cleave)
var repeatIdx:int = 0
var totalRepeats:int = 0

func resolveCost():
	if action is UseableSkill:
		var skill = action as UseableSkill
		# take off MP
		var cost = skill.getMPCost(battler.battler)
		battler.battler.changeMP(-cost)
		# set cooldown
		var skId = skill.getId()
		if skill.cooldown != 0:
			battler.battler.setSkillCooldown(skId, skill.cooldown+1)
		# add spent charge
		if skill.charges != 0:
			battler.battler.addSkillChargesSpent(skId)
		# reduce atb
		battler.atbValue -= skill.cpCost
	elif action is UseableItem:
		var item = action as UseableItem
		# remove 1 of item on chance
		var r = randf()
		if (r < item.spendOnUseChance):
			Global.State.party.loseItem(item.getId(), 1)
		# reduce atb
		battler.atbValue -= item.cpCost

func selectSpecificTarget(t:Battler):
	var targetKind = Global.ETargetKind.ENEMY
	var targetState = Global.ETargetState.ALIVE
	if action is Status:
		targetKind = Global.ETargetKind.USER
		targetState = Global.ETargetState.ANY
	elif action is UseableSkill:
		var sk = action as UseableSkill
		targetKind = sk.targetKind
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetKind = it.targetKind
		targetState = it.targetState
	var ary = getTargetArray(targetKind,targetState)
	if ary.size()==0: 
		targetIdx = 0
	else:
		targetIdx = ary.find(t)
		if targetIdx==-1:
			targetIdx = randi() % ary.size()
func selectRandomTarget():
	var targetKind = Global.ETargetKind.ENEMY
	var targetState = Global.ETargetState.ALIVE
	if action is Status:
		targetKind = Global.ETargetKind.USER
		targetState = Global.ETargetState.ANY
	elif action is UseableSkill:
		var sk = action as UseableSkill
		targetKind = sk.targetKind
		targetState = sk.targetState
	elif action is UseableItem:
		var it = action as UseableItem
		targetKind = it.targetKind
		targetState = it.targetState
	var ary = getTargetArray(targetKind,targetState)
	if ary.size()==0: 
		targetIdx = 0
	else:
		targetIdx = randi() % ary.size()

func setRepeats():
	totalRepeats = resolveRepeats()
	repeatIdx = 0
func repeatAvailable():
	return repeatIdx <= totalRepeats;
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
	elif action is Status:
		var st = action as Status
		return st.eotSequence
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
	elif action is Status:
		targetKind = Global.ETargetKind.USER
		targetState = Global.ETargetState.ANY
	var ary = getTargetArray(targetKind,targetState)
	match scope:
		Global.ETargetScope.ALL:
			return ary
		Global.ETargetScope.ONE:
			if ary.size()==0: return []
			return [ary[targetIdx % ary.size()]]
		_:
			if ary.size()==0: return []
			var rndIdx = randi() % ary.size()
			return [ary[rndIdx]]

func getTargetArray(kind:Global.ETargetKind,state:Global.ETargetState):
	# Invert kind if is i.e. confused
	if battler.battler.hasRestriction(Global.ERestriction.AttackAlly):
		match kind:
			Global.ETargetKind.ENEMY:
				kind = Global.ETargetKind.ALLY
			Global.ETargetKind.ALLY:
				kind = Global.ETargetKind.ENEMY
			Global.ETargetKind.ANY:
				kind = Global.ETargetKind.ALLY
	# Return the array of viable targets
	match kind:
		Global.ETargetKind.ENEMY:
			return battler.getEnemies(state)
		Global.ETargetKind.ALLY:
			return battler.getAllies(state)
		Global.ETargetKind.ANY:
			return battler.getAll(state)
		Global.ETargetKind.USER:
			return [battler]
		_:
			return []
