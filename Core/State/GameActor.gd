extends GameBattler
class_name GameActor

var name : String
var position : int = 0
var exp : int
var equips : Array
var _expList : Array[int] = []
var currWeapon : int = -1
var currAP : int
var apPerc : int

var availableSkills:Array
var learnedSkills:Array

func _init(_id:StringName):
	id = _id
	var actor:Actor = getData()
	if (actor == null): return
	name = actor.name
	level = actor.startLevel
	currHP = getMaxHP()
	currMP = getMaxMP()
	makeExpList()
	# Resize array if needed
	var _slotsData = Global.Db.equipSlots
	if(equips.size() < _slotsData.size()):
		equips.resize(_slotsData.size())
	# Set starting equipment
	for item in actor.startingEquipment:
		for i in range(_slotsData.size()):
			var s = _slotsData[i].kind
			if item.slot==s && equips[i]==null && canEquip(item):
				equips[i] = item.getId()
				break
	# Set starting skills
	for learningSlot in actor.learningSlots:
		learnSlot(learningSlot)

func getName():
	return name

func getPosition() -> int:
	return position

func getSkills():
	var skills = []
	var _slotData:Array[SlotData] = Global.Db.equipSlots
	# Equip skills
	for i in range(_slotData.size()):
		if _slotData[i].kind==Global.EquipSlot.ARMS:
			var e = equips[i]
			if(e == null):
				var idx = getData().defaultWeaponSkills[i]
				var skill = Global.Db.defaultAttackSkills[idx] as UseableSkill
				skills.append(skill)
			else:
				var item = Global.Db.getItem(e) as EquipItem
				skills.append(item.skill)
	# Available skills
	for s in availableSkills:
		var skill = Global.Db.getSkill(s)
		if skill is UseableSkill:
			skills.append(skill)
	#TODO Fylgja and scrolls?
	return skills

func learnSlot(learningSlot:SkillLearningSlot):
	if learningSlot==null: return false
	var prevLearn:SkillLearning = null
	for learning in learningSlot.learnings:
		if _isLearned(learning):
			prevLearn = learning
		else:
			_learn(learning)
			if prevLearn != null:
				availableSkills.erase(prevLearn.skill.getId())
			return true
	return false
func getCurrentLearningFromSlot(learningSlot:SkillLearningSlot):
	for learning in learningSlot.learnings:
		if !_isLearned(learning):
			return learning
	return null
func hasBaseRequirements(learningSlot:SkillLearningSlot):
	if learningSlot.learnings.size()==0: return false
	var l = learningSlot.learnings[0]
	for req in l.requirements:
		if !learnedSkills.has(req.getId()): return false
	return true
func _isLearned(learning:SkillLearning):
	return learnedSkills.has(learning.skill.getId())
func _learn(learning:SkillLearning):
	if learning.apCost > currAP: return false
	for req in learning.requirements:
		if !learnedSkills.has(req.getId()): return false
	# Apply cost
	currAP -= learning.apCost
	# Learn
	var id = learning.skill.getId()
	learnedSkills.append(id)
	availableSkills.append(id)
	return true

func getCurrWeaponIdx():
	if currWeapon<0: return 0
	return currWeapon

func getFeatures():
	var actor:Actor = getData()
	var features = []
	# Base features
	features.append_array(actor.features)
	# Equip features
	for i in range(equips.size()):
		var e = equips[i]
		if(e != null):
			var data = Global.Db.getItem(e)
			if data is EquipItem:
				var equip = data as EquipItem
				if equip.slot==Global.EquipSlot.ARMS:
					if i != getCurrWeaponIdx():
						continue
				features.append_array(equip.features)
	# Status features
	for s in states:
		var data:Status = Global.Db.getStatus(s.id)
		features.append_array(data.features)
	# Passive skill features
	for s in availableSkills:
		var skill = Global.Db.getSkill(s)
		if skill is PassiveSkill:
			var passive = skill as PassiveSkill
			features.append_array(passive.features)
	return features

func getBaseMaxHP():
	var actor:Actor = getData()
	return calcBaseStat(actor.mhp.x, actor.mhp.y, level)
func getBaseMaxMP():
	var actor:Actor = getData()
	return calcBaseStat(actor.mmp.x, actor.mmp.y, level)
func getBaseStr():
	var actor:Actor = getData()
	return calcBaseStat(actor.str.x, actor.str.y, level)
func getBaseVit():
	var actor:Actor = getData()
	return calcBaseStat(actor.vit.x, actor.vit.y, level)
func getBaseMag():
	var actor:Actor = getData()
	return calcBaseStat(actor.mag.x, actor.mag.y, level)
func getBaseAgi():
	var actor:Actor = getData()
	return calcBaseStat(actor.agi.x, actor.agi.y, level)

func calcBaseStat(base:int, mult:int, level:int) -> int:
	var lm : float = (mult * (level - 1)) / 100.0
	var m : float = (lm + 10.0) / 10.0
	return roundi(base * m)

func makeExpList():
	if _expList.size() != 0: return
	_expList.resize(Actor.MAX_LEVEL)
	var data = getData()
	var pow_i = 2.4 + (data.expGrowth.y/100.0)
	var div = pow(5.0, pow_i)
	for i in range(Actor.MAX_LEVEL):
		if i<=1:
			_expList[i] = 0
		else:
			var n = data.expGrowth.x * pow((i+3.0),pow_i) / div
			_expList[i] = _expList[i-1] + roundi(n)

func getLevelExp(l:int):
	if l < 1: return 0
	if l > Actor.MAX_LEVEL: return 0
	makeExpList()
	return _expList[l]
func getNextLvlExp():
	return getLevelExp(level+1)
func getRemainingNextLvlExp():
	return getLevelExp(level+1)-getLevelExp(level)

func getEquip(slotIdx:int):
	var e = equips[slotIdx]
	if (e==null): return null
	return Global.Db.getItem(e)
func equip(slotIdx:int, item:EquipItem):
	# Resize array if needed
	var _slotsData = Global.Db.equipSlots
	if(equips.size() < _slotsData.size()):
		equips.resize(_slotsData.size())
	# add new item into the slot
	if(item != null):
		# check if it's for the right slot
		if _slotsData[slotIdx].kind != item.slot: return false
		# Can't equip
		if(canEquip(item) == false): return false
		# Wrong slot
		if(item.slot != _slotsData[slotIdx].kind): return false
	# remove current item at slot, send back to inventory
	if(equips[slotIdx] != null):
		var oldEquip = equips[slotIdx]
		equips[slotIdx] = null
		Global.State.party.gainItem(oldEquip,1)
	# Equip
	if(item != null):
		var newEquip = item.getId()
		equips[slotIdx] = newEquip
		Global.State.party.loseItem(newEquip,1)
	return true
func canEquip(equip:EquipItem)->bool:
	var a:Actor = getData()
	for flag in equip.flags:
		if a.equippableFlags.has(flag)==false:
			return false
	return true

func getData():
	if id=="": return null
	return Global.Db.getActor(id)

func getInnateElement():
	return getData().innateElement

func getBattleGraphic():
	return getData().battleSprite
func getSmallFace():
	return getData().faceSmall

func _serialize():
	var savedata = {
		"id" : id,
		"name" : name,
		"level" : level,
		"position" : position,
		"exp" : exp,
		"currHP" : currHP,
		"currMP" : currMP,
		"states" : _serializeStates(),
		"equips" : equips,
		"learnedSkills" : learnedSkills,
		"availableSkills" : availableSkills,
		"currAP" : currAP,
		"apPerc" : apPerc,
		"lastIndexes" : lastIndexes,
		"skillConditions" : skillConditions
	}
	return savedata
func _serializeStates():
	var data = []
	for s in states:
		data.append(s._serialize())
	return data
func _deserialize(savedata : Dictionary):
	for key in savedata:
		match key:
			"equips":
				equips = savedata[key]
			"learnedSkills":
				learnedSkills = savedata[key]
			"availableSkills":
				availableSkills = savedata[key]
			_:
				set(key, savedata[key])
func _deserializeStates(data:Array):
	states.clear()
	for s in data:
		var ss = StatusState.new()
		ss._deserialize(s)
		states.append(ss)

func automatic():
	return false
func isEnemy(other:GameBattler):
	if other is GameEnemy:
		return true
	return false

func getActionScriptList() -> Array[ActionScript]:
	return [ActionScript.new()]
