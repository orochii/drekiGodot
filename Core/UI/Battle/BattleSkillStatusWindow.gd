extends Control
class_name BattleSkillStatusWindow

@export var face:NinePatchRect
@export var hpParent:NinePatchRect
@export var hpBar:NinePatchRect
@export var hpNum:Label
@export var mpParent:NinePatchRect
@export var mpBar:NinePatchRect
@export var mpNum:Label

@export var costLabel:Label
@export var costNum:Label
@export var cooldown:Control
@export var cooldownCount:Label
@export var charges:Control
@export var chargesCount:Label
@export var reason:Label

var battler:Battler = null
var _skill:UseableSkill = null
var barOriginalWidth
var hpCurr
var mpCurr

func setBattler(b:Battler):
	battler = b
	face.texture = b.battler.getSmallFace()
	_refreshStatus()

func setup(skill:UseableSkill):
	_skill = skill
	if battler == null: return
	_refreshCost()
	_refreshStatus()
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
		elif chargesRemaining <= 0 && skill.charges != 0:
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
		if (mpCurr != battler.battler.currMP) || (hpCurr != battler.battler.currHP):
			_refreshStatus()
			_refreshCost()

func _refreshStatus():
	hpCurr = battler.battler.currHP
	mpCurr = battler.battler.currMP
	if _skill==null: return
	match _skill.getCostKind():
		0:
			var perc = mpCurr * 1.0 / battler.battler.getMaxMP()
			mpNum.text = "%d" % mpCurr
			_setBarWidth(mpBar,perc)
		1:
			var perc = hpCurr * 1.0 / battler.battler.getMaxHP()
			hpNum.text = "%d" % hpCurr
			_setBarWidth(hpBar,perc)

func _refreshCost():
	hpParent.visible = false
	mpParent.visible = false
	if _skill != null:
		match _skill.getCostKind():
			0:
				mpParent.visible = true
				costLabel.text = "MP Cost"
				costNum.text = "%d" % _skill.getMPCost(battler.battler)
			1:
				hpParent.visible = true
				costLabel.text = "HP Cost"
				costNum.text = "%d" % _skill.getHPCost(battler.battler)
			_:
				costLabel.text = ""
				costNum.text = "Free"
	else:
		costNum.text = ""

func _setBarWidth(bar,percent:float):
	var size = bar.texture.get_size()
	bar.region_rect.size.x = roundi(percent * size.x)
	bar.region_rect.size.y = size.y
	bar.size.x = roundi(percent * barOriginalWidth)
