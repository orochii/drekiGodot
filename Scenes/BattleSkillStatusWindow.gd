extends Control
class_name BattleSkillStatusWindow

@export var face:NinePatchRect
@export var mpBar:NinePatchRect
@export var mpNum:Label

@export var mpCost:Label
@export var cooldown:Control
@export var cooldownCount:Label
@export var charges:Control
@export var chargesCount:Label
@export var reason:Label

var battler:Battler = null
var _skill:UseableSkill = null
var barOriginalWidth
var mpCurr

func setBattler(b:Battler):
	battler = b
	face.texture = b.battler.getSmallFace()
	_refreshStatus()

func setup(skill:UseableSkill):
	_skill = skill
	_refreshCost()
	if _skill == null:
		cooldown.visible = false
		charges.visible = false
		reason.text = ""
	else:
		var id = skill.getId()
		var currCooldown = battler.battler.getSkillCooldown(id)
		var chargesSpent = battler.battler.getSkillChargesSpent(id)
		var chargesRemaining = skill.charges - chargesSpent
		if currCooldown != 0:
			cooldown.visible = false
			charges.visible = false
			reason.text = "Cooldown %d turns" % currCooldown
		if chargesRemaining <= 0 && skill.charges != 0:
			cooldown.visible = false
			charges.visible = false
			reason.text = "Depleted"
		else:
			cooldown.visible = skill.cooldown != 0
			charges.visible = skill.charges != 0
			reason.text = ""
			cooldownCount.text = "%d" % skill.cooldown
			chargesCount.text = "%d/%d" % [chargesRemaining, skill.charges]

func _ready():
	barOriginalWidth = mpBar.size.x

func _process(delta):
	if is_visible_in_tree():
		if battler==null: return
		if mpCurr != battler.battler.currHP:
			_refreshStatus()
			_refreshCost()

func _refreshStatus():
	mpCurr = battler.battler.currHP
	var mpPerc = mpCurr * 1.0 / battler.battler.getMaxHP()
	mpNum.text = "%d" % mpCurr
	_setMpBarWidth(mpPerc)

func _refreshCost():
	if _skill != null:
		mpCost.text = "%d" % _skill.getMPCost(battler.battler)
	else:
		mpCost.text = ""

func _setMpBarWidth(percent:float):
	var size = mpBar.texture.get_size()
	mpBar.region_rect.size.x = roundi(percent * size.x)
	mpBar.region_rect.size.y = size.y
	mpBar.size.x = roundi(percent * barOriginalWidth)
