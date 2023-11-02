extends Control
class_name SkillList

@export var container:Container
@export var skillEntryTemplate:PackedScene
@export var scroll:ScrollContainer
@export var cursor:AnimatedSprite2D

var inBattle:bool = false
var onSkillSelected:Callable
var entries:Array[SkillEntry]
var active:bool = false

func _ready():
	cursor.visible = false
	cursor.play("default")

func _process(delta):
	if(visible==false): return
	if(active==false): return
	var focused = get_viewport().gui_get_focus_owner()
	if entries.has(focused):
		scroll.ensure_control_visible(focused)
		cursor.global_position = focused.global_position + Vector2(2,8)
		cursor.visible = true
	else:
		cursor.visible = false

func setup(battler:GameBattler):
	for e in entries: e.queue_free()
	entries.clear()
	if(battler==null): return
	var skills = battler.getSkills()
	for skill in skills:
		var inst:SkillEntry = skillEntryTemplate.instantiate()
		inst.setEnabled(skill.isUseable(inBattle))
		inst.setup(skill)
		inst.skillSelected.connect(_onSelected)
		container.add_child(inst)
		entries.append(inst)
	UIUtils.setGridNeighbors(entries,2)

func getFirst():
	if(entries.size() == 0): return null
	return entries[0]

func getListIndex():
	var focused = get_viewport().gui_get_focus_owner()
	return entries.find(focused)

func setListIndex(idx:int):
	if(idx >= 0 && idx < entries.size()):
		entries[idx].grab_focus()
	else:
		var f = getFirst()
		if(f != null): f.grab_focus()

func getCurrentItem():
	var focused = get_viewport().gui_get_focus_owner()
	if entries.has(focused):
		return focused.skill
	return null

func _onSelected(skillEntry, skill):
	if !skillEntry.enabled:
		Global.Audio.playSFX("buzzer")
		return
	if onSkillSelected.is_valid():
		onSkillSelected.call(skillEntry, skill)
