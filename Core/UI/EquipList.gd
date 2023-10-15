extends ScrollContainer
class_name EquipList

@export var container:Container
@export var equipLineTemplate:PackedScene
@export var equipScreen:CharacterEquipScreen
var slots:Array
var actor:GameActor

func _ready():
	var _slots = Global.Db.equipSlots
	for i in range(_slots.size()):
		var inst = equipLineTemplate.instantiate()
		inst.setSlot(i,equipScreen)
		container.add_child(inst)
		slots.append(inst)
	UIUtils.setVNeighbors(slots)

func _process(delta):
	# Scroll to focused control
	var focused = get_viewport().gui_get_focus_owner()
	if slots.has(focused):
		ensure_control_visible(focused)

func setActor(_actor:GameActor):
	actor = _actor
	for i in range(slots.size()):
		if actor.equips.size() > i && actor.equips[i] != null:
			var item = Global.Db.getItem(actor.equips[i])
			slots[i].setup(item)
		else:
			slots[i].setup(null)

func focus(i:int=0):
	Global.Audio.resetLastFocused()
	slots[i].grab_focus()
