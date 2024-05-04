extends NinePatchRect
class_name ItemUseSubscreen

@export var parentScreen : MenuScreen
@export var itemSpawner : ItemSpawner
@export var partyTargetTemplate : PackedScene
@export var itemEntry : ItemEntry
@export var description : RichTextLabel
@export var container : Container
@export var cursor : AnimatedSprite2D

var curr : ItemEntry
var targetList : Array[PartyTargetEntry]
var scope : Global.ETargetScope
var currTargetAllIdx : int

func _ready():
	cursor.play("default")
	visible = false

func setItem(entry:ItemEntry):
	parentScreen.active = false
	visible = true
	curr = entry
	itemEntry.setup(entry.entry)
	if itemEntry.data is UseableItem:
		var item = itemEntry.data as UseableItem
		scope = item.targetScope
		currTargetAllIdx = 0
	description.text = itemEntry.data.getDesc()
	get_viewport().gui_release_focus()
	refreshTargets()

func refreshTargets():
	for e in targetList: e.queue_free()
	targetList.clear()
	
	if curr.canUse:
		var members : Array = Global.State.party.getMembers()
		for i in range(members.size()):
			var m = members[i]
			var inst = partyTargetTemplate.instantiate()
			container.add_child(inst)
			inst.setupUse(m)
			inst.onPressed = onItemUsed
			targetList.append(inst)
		UIUtils.setVNeighbors(targetList)
		if targetList.size() != 0: targetList[0].grab_focus()
	elif itemEntry.data is EquipItem:
		var members : Array = Global.State.party.getMembers()
		for i in range(members.size()):
			var m = members[i]
			var inst:PartyTargetEntry = partyTargetTemplate.instantiate()
			container.add_child(inst)
			inst.setupEquip(m,itemEntry.data)
			targetList.append(inst)

func onItemUsed(target):
	# check if you got enough items
	var count = Global.State.party.itemCount(itemEntry.data.getId())
	if count <= 0:
		Global.Audio.playSFX("buzzer")
		return
	# Set targets, depends on if we're on single scope or multiple scope.
	if itemEntry.data is UseableItem:
		var effective = false
		var item = itemEntry.data as UseableItem
		var targets = _resolveTargets(target,item)
		# Apply item effects on targets.
		for t in targets:
			for eff in item.actionSequence:
				var result = eff.apply(t.actor, t.actor)
				if result.has("effective"):
					effective = effective || result["effective"]
		if effective:
			# Take item
			var r = randf()
			if (r < item.spendOnUseChance):
				Global.State.party.loseItem(item.getId(), 1)
			itemEntry._refresh()
			curr = itemSpawner.refresh(curr)
			# Refresh targets
			for t in targets:
				t.refreshUse()
				t.triggerUseEffect()
			Global.Audio.playSFX("item")
			return
	# Can't use, do buzzer
	Global.Audio.playSFX("buzzer")

func _process(delta):
	if(!visible):return
	var focused = get_viewport().gui_get_focus_owner()
	if(targetList.has(focused)):
		positionCursor(focused)
	else:
		cursor.visible = false
	if(Input.is_action_just_pressed("action_cancel")):
		Global.Audio.playSFX("cancel")
		visible = false
		parentScreen.active = true
		curr.grab_focus()

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

func _resolveTargets(target:PartyTargetEntry,item:UseableItem):
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
