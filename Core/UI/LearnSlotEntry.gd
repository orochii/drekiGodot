extends Control
class_name LearnSlotEntry

@export var skillContainer:Control
@export var icon:NinePatchRect
@export var learnCost:Label
@export var upgradeCost:Label

var actor:GameActor
var slot:SkillLearningSlot

func setup(_actor,_slot:SkillLearningSlot):
	actor = _actor
	slot = _slot
	if actor.hasBaseRequirements(slot):
		var learning:SkillLearning = actor.getCurrentLearningFromSlot(slot)
		var idx = slot.learnings.find(learning)
		if(learning==null): learning = slot.learnings[-1]
		if idx==-1: # Max learning
			learnCost.text = ""
			upgradeCost.text = ""
		elif idx==0: # Learn
			learnCost.text = "%d" % learning.apCost
			upgradeCost.text = ""
		else: # Upgrade
			learnCost.text = ""
			upgradeCost.text = "%d" % learning.apCost
		icon.texture = learning.skill.icon
		skillContainer.visible = true
	else:
		skillContainer.visible = false
	position = Vector2(slot.gridPosition) * 16
	#
