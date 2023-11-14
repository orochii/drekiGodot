extends Control
class_name SkillInfo

@export var skillIcon:NinePatchRect
@export var skillName:Label
@export var skillDesc:RichTextLabel
@export var skillCost:Label
@export var turnIcon:NinePatchRect
@export var turnLabel:Label
@export var chargeIcon:NinePatchRect
@export var chargeLabel:Label

var actor = null
var skill = null

func setup(_actor:GameActor,_skill:BaseSkill):
	actor = _actor
	skill = _skill
	refresh()

func refresh():
	skillIcon.texture = skill.icon
	skillName.text = skill.getName()
	skillDesc.text = skill.getDesc()
	if skill is UseableSkill:
		var useable = skill as UseableSkill
		# MP Cost
		skillCost.visible = true
		skillCost.text = useable.getMPCostString()
		# Cooldown info
		if useable.cooldown != 0:
			turnIcon.visible = true
			turnLabel.visible = true
			turnLabel.text = "%d" % useable.cooldown
		else:
			turnIcon.visible = false
			turnLabel.visible = false
		# Charges info
		if useable.charges != 0:
			chargeIcon.visible = true
			chargeLabel.visible = true
			var spentCharges = actor.getSkillChargesSpent(useable.getId())
			var availableCharges = useable.charges - spentCharges
			chargeLabel.text = "%d/%d" % [availableCharges, useable.cooldown]
		else:
			chargeIcon.visible = false
			chargeLabel.visible = false
	else:
		skillCost.visible = false
		turnIcon.visible = false
		turnLabel.visible = false
		chargeIcon.visible = false
		chargeLabel.visible = false
