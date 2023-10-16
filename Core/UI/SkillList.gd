extends Control
class_name SkillList

@export var container:Container
@export var skillEntryTemplate:PackedScene
@export var scroll:ScrollContainer
@export var cursor:AnimatedSprite2D

var entries:Array[SkillEntry]
var active:bool = false

func _ready():
	cursor.visible = false
	cursor.play("default")

func _process(delta):
	if(active==false): return
	var focused = get_viewport().gui_get_focus_owner()
	if entries.has(focused):
		scroll.ensure_control_visible(focused)
		cursor.global_position = focused.global_position + Vector2(2,8)
		cursor.visible = true
	else:
		cursor.visible = false

func setup(actor:GameActor):
	for e in entries: e.queue_free()
	entries.clear()
	if(actor==null): return
	var skills = actor.getSkills()
	for skill in skills:
		var inst:SkillEntry = skillEntryTemplate.instantiate()
		inst.setup(skill)
		if skill==null: print(skill)
		else: print(skill.resource_path)
		container.add_child(inst)
		entries.append(inst)
	UIUtils.setGridNeighbors(entries,2)

func getFirst():
	if(entries.size() == 0): return null
	return entries[0]
