extends NinePatchRect
class_name ItemUseSubscreen

@export var parentScreen : MenuScreen
@export var partyTargetTemplate : PackedScene
@export var itemEntry : ItemEntry
@export var description : RichTextLabel
@export var container : Container

var curr : ItemEntry
var targetList : Array[PartyTargetEntry]

func _ready():
	visible = false

func setItem(entry:ItemEntry):
	parentScreen.active = false
	visible = true
	curr = entry
	itemEntry.setup(entry.entry,self)
	description.text = itemEntry.data.description
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
		#TODO: Show if item is equippable.
		var members : Array = Global.State.party.members
		for i in range(members.size()):
			var m = members[i]
			var inst = partyTargetTemplate.instantiate()
			container.add_child(inst)
			inst.setupEquip(m,itemEntry.data)
			targetList.append(inst)

func _process(delta):
	if(!visible):return
	if(Input.is_action_just_pressed("action_cancel")):
		Global.Audio.playSFX("cancel")
		visible = false
		parentScreen.active = true
		curr.grab_focus()
