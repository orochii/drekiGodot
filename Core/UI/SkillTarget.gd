extends Container
class_name SkillTarget

@export var partyTargetTemplate : PackedScene
@export var container : Container
@export var actorStats : CharacterStats
@export var skillInfo : SkillInfo
@export var targetsWindow : Control
@export var menuScreen : MenuScreen
@export var cursor : AnimatedSprite2D

var targetList = []
var prevFocus = null
var currentSkill:UseableSkill = null
var scope : Global.ETargetScope
var currTargetAllIdx : int
var actor:GameActor

func _ready():
	cursor.play("default")
	visible = false

func _process(delta):
	if !visible: return
	var focused = get_viewport().gui_get_focus_owner()
	if(targetList.has(focused)):
		positionCursor(focused)
	if currentSkill != null:
		if currentSkill.targetCanChangeScope:
			if Input.is_action_just_pressed("cycle_left")||Input.is_action_just_pressed("cycle_right"):
				if scope == currentSkill.targetScope:
					scope = Global.ETargetScope.ALL
				else:
					scope = currentSkill.targetScope
	if Input.is_action_just_pressed("action_cancel"):
		close()

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		if scope == Global.ETargetScope.ONE:
			cursor.global_position = focused.global_position + Vector2(10,8)
		else:
			var _currTarget = targetList[currTargetAllIdx]
			cursor.global_position = _currTarget.global_position + Vector2(10,8)
			currTargetAllIdx = (currTargetAllIdx+1) % targetList.size()
	else:
		cursor.visible = false

func open(_actor:GameActor, skill:BaseSkill):
	actor = _actor
	menuScreen.active = false
	prevFocus = get_viewport().gui_get_focus_owner()
	get_viewport().gui_release_focus()
	visible = true
	# Clear any existing entry
	for e in targetList: e.queue_free()
	targetList.clear()
	# Setup skill info
	skillInfo.setup(actor, skill)
	# a
	if skill is UseableSkill:
		currentSkill = skill as UseableSkill
		scope = currentSkill.targetScope
		currTargetAllIdx = 0
		# Get useable targets
		var targets = []
		match currentSkill.targetKind:
			Global.ETargetKind.ALLY,Global.ETargetKind.ANY:
				var members : Array = Global.State.party.members
				for i in range(members.size()):
					var m = members[i]
					targets.append(m)
			Global.ETargetKind.USER:
				targets.append(actor.id)
		# Spawn targets
		for m in targets:
			var inst:PartyTargetEntry = partyTargetTemplate.instantiate()
			container.add_child(inst)
			inst.setupUse(m)
			inst.onPressed = onSkillUsed
			targetList.append(inst)
		UIUtils.setVNeighbors(targetList)
		targetsWindow.visible = true
		if targetList.size() != 0:
			targetList[0].grab_focus()
	else:
		targetsWindow.visible = false

func close():
	menuScreen.active = true
	if prevFocus != null: prevFocus.grab_focus()
	else: get_viewport().gui_release_focus()
	visible = false

func onSkillUsed(target):
	# Set targets, depends on if we're on single scope or multiple scope.
	if currentSkill != null:
		var canUse = actor.canUse(currentSkill)
		if !canUse:
			Global.Audio.playSFX("buzzer")
			return
		var effective = false
		var targets = _resolveTargets(target,currentSkill)
		# Apply item effects on targets.
		for t in targets:
			for eff in currentSkill.actionSequence:
				var result = eff.apply(actor, t.actor)
				if result.has("effective"):
					effective = effective || result["effective"]
		if effective:
			# Apply cost
			actor.resolveSkillCost(currentSkill,false)
			# Refresh targets
			for t in targets:
				t.refreshUse()
				t.triggerUseEffect()
			skillInfo.refresh()
			Global.Audio.playSFX("item")
			return
	# Can't use, do buzzer
	Global.Audio.playSFX("buzzer")

func _resolveTargets(target:PartyTargetEntry,item:UseableSkill):
	match item.targetKind:
		Global.ETargetKind.ENEMY,Global.ETargetKind.NONE:
			return []
		_:
			var targets = []
			match scope:
				Global.ETargetScope.ALL:
					for tt in targetList:
						if tt.actor.stateConditionMet(item.targetState):
							targets.append(tt)
				_:
					if target.actor.stateConditionMet(item.targetState):
						targets.append(target)
			return targets
