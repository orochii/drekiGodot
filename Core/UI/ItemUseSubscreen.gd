extends NinePatchRect
class_name ItemUseSubscreen

@export var parentScreen : MenuScreen
@export var partyTargetTemplate : PackedScene
@export var itemEntry : ItemEntry
@export var description : RichTextLabel
@export var container : Container
@export var cursor : AnimatedSprite2D

var curr : ItemEntry
var targetList : Array[PartyTargetEntry]

func _ready():
	cursor.play("default")
	visible = false

func setItem(entry:ItemEntry):
	parentScreen.active = false
	visible = true
	curr = entry
	itemEntry.setup(entry.entry)
	description.text = itemEntry.data.getDesc()
	get_viewport().gui_release_focus()
	refreshTargets()

func refreshTargets():
	for e in targetList: e.queue_free()
	targetList.clear()
	
	if curr.canUse:
		var members : Array = Global.State.party.members
		for i in range(members.size()):
			var m = members[i]
			var inst = partyTargetTemplate.instantiate()
			container.add_child(inst)
			inst.setupUse(m)
			targetList.append(inst)
		UIUtils.setVNeighbors(targetList)
		if targetList.size() != 0: targetList[0].grab_focus()
	elif itemEntry.data is EquipItem:
		var members : Array = Global.State.party.members
		for i in range(members.size()):
			var m = members[i]
			var inst = partyTargetTemplate.instantiate()
			container.add_child(inst)
			inst.setupEquip(m,itemEntry.data)
			targetList.append(inst)

func _process(delta):
	if(!visible):return
	var focused = get_viewport().gui_get_focus_owner()
	if(targetList.has(focused)):
		positionCursor(focused)
	if(Input.is_action_just_pressed("action_cancel")):
		Global.Audio.playSFX("cancel")
		visible = false
		parentScreen.active = true
		curr.grab_focus()

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(10,8)
	else:
		cursor.visible = false
