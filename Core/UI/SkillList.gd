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
var _battler:GameBattler = null

func _ready():
	cursor.visible = false
	cursor.play("default")

func _process(delta):
	if(visible==false): return
	if(active==false): return
	var focused = get_viewport().gui_get_focus_owner()
	
	if focused is SkillEntry && entries.has(focused):
		scroll.ensure_control_visible(focused)
		cursor.global_position = focused.global_position + Vector2(2,8)
		cursor.visible = true
	else:
		cursor.visible = false

func setup(battler:GameBattler):
	for e in entries: e.queue_free()
	entries.clear()
	if(battler==null): return
	_battler = battler
	var skills = battler.getSkills()
	for skill in skills:
		var inst:SkillEntry = skillEntryTemplate.instantiate()
		if skill != null:
			inst.setEnabled(skill.isUseable(inBattle) && _battler.canUse(skill))
		else:
			inst.setEnabled(false)
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
	if !skillEntry.enabled && inBattle:
		Global.Audio.playSFX("buzzer")
		return
	if onSkillSelected.is_valid():
		onSkillSelected.call(skillEntry, skill)

func _connectToUI():
	if !Global.UI.onHpChange.is_connected(_onHpChange):
		Global.UI.onHpChange.connect(_onHpChange)
		Global.UI.onMpChange.connect(_onMPChange)
		Global.UI.onStatusChange.connect(_onStatusChange)
		_onHpChange(_battler,true)
		_onMPChange(_battler,true)

func _disconnectToUI():
	if Global.UI.onHpChange.is_connected(_onHpChange):
		Global.UI.onHpChange.disconnect(_onHpChange)
		Global.UI.onMpChange.disconnect(_onMPChange)
		Global.UI.onStatusChange.disconnect(_onStatusChange)

func _onHpChange(b,max):
	if _battler==null: return
	if b != _battler: return
	_refreshCanUse()
func _onMPChange(b,max):
	if _battler==null: return
	if b != _battler: return
	_refreshCanUse()
func _onStatusChange(b):
	if _battler==null: return
	if b != _battler: return
	_refreshCanUse()

func _exit_tree():
	_disconnectToUI()

func _refreshCanUse():
	for e in entries:
		if e.skill != null:
			e.setEnabled(e.skill.isUseable(inBattle) && _battler.canUse(e.skill))
		else:
			e.setEnabled(false)
