extends Control
class_name LearnSlotEntry

@export var skillContainer:Control
@export var icon:NinePatchRect
@export var learnCost:Label
@export var upgradeCost:Label

var actor:GameActor
var slot:SkillLearningSlot
var currentSkill:BaseSkill
var currentApCost:int
var maxed:bool = false

func setup(_actor,_slot:SkillLearningSlot):
	actor = _actor
	slot = _slot
	if actor.hasBaseRequirements(slot):
		var learning:SkillLearning = actor.getCurrentLearningFromSlot(slot)
		var idx = slot.learnings.find(learning)
		maxed = false
		currentApCost = 0
		if(learning==null): 
			learning = slot.learnings[-1]
			maxed = true
		if idx==-1: # Max learning
			learnCost.text = ""
			upgradeCost.text = ""
		elif idx==0: # Learn
			currentApCost = learning.apCost
			learnCost.text = "%d" % learning.apCost
			upgradeCost.text = ""
		else: # Upgrade
			currentApCost = learning.apCost
			learnCost.text = ""
			upgradeCost.text = "%d" % learning.apCost
		currentSkill = learning.skill
		icon.texture = currentSkill.icon
		skillContainer.visible = true
	else:
		skillContainer.visible = false
	position = Vector2(slot.gridPosition) * 16
	#
