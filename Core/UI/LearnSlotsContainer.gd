extends BaseWindow
class_name LearnSlotsContainer

const DELAY:float = 0.25
const SHORT:float = 0.05

@export var lineContainer:Control
@export var slotsContainer:Control
@export var skillLearn:Control
@export var learnSlotTemplate:PackedScene
@export var parentScreen:CharacterActionsScreen

var actor:GameActor
var data:Actor
var instancedSlots:Array[LearnSlotEntry]
var instancedEdges:Array[Line2D]
var cursorPosition:Vector2i
var active:bool = false
var moveDelay:float = 0
var lastLearned:Vector2i = Vector2i(-1,-1)

func _ready():
	cursor.play("default")
	refreshCursorPos()

func setup(_actor:GameActor):
	actor = _actor
	if(actor==null): return
	data = actor.getData()
	if(data==null): return
	refresh()
	# active = true

func refresh():
	for i in instancedSlots: i.queue_free()
	instancedSlots.clear()
	for i in instancedEdges: i.queue_free()
	instancedEdges.clear()
	#
	for i in range(data.learningSlots.size()):
		var slot = data.learningSlots[i]
		if(slot==null): continue
		if(slot.gridPosition.x < 0): continue
		var inst:LearnSlotEntry = learnSlotTemplate.instantiate()
		inst.setup(actor,slot)
		slotsContainer.add_child(inst)
		instancedSlots.append(inst)
		if lastLearned == slot.gridPosition:
			_setLearnedAnimation(inst)
	#
	for i in instancedSlots:
		if i.slot.learnings.size()==0: continue
		#i.slot.learnings[0].requirements
		var reqs = []
		for s in i.slot.learnings: reqs.append(s.skill)
		for j in instancedSlots:
			if j.slot.learnings.size()==0: continue
			var _hasReq = false
			for s in reqs:
				if j.slot.learnings[0].requirements.has(s):
					_hasReq = true
			if _hasReq:
				var srcPos = i.position + Vector2(8,8)
				var dstPos = j.position + Vector2(8,8)
				var line = Line2D.new()
				line.add_point(srcPos)
				line.add_point(Vector2(srcPos.x,dstPos.y))
				line.add_point(dstPos)
				line.width = 1
				lineContainer.add_child(line)
				instancedEdges.append(line)

func _setLearnedAnimation(_slot:LearnSlotEntry):
	print("Last Learned: %s" % lastLearned)
	_slot.modulate = Color(5.0,5.0,5.0,1.0)
	var _tween = create_tween()
	_tween.tween_property(_slot, "modulate", Color.WHITE, 1)
	lastLearned = Vector2i(-1,-1)

func _process(delta):
	if Global.UI.Config.visible: return
	if(!self.is_visible_in_tree()): return
	cursor.visible = active
	if !active: return
	# <>
	if Global.Inputs.isRepeating("move_left"):
		cursorPosition.x = clamp(cursorPosition.x-1, 0, 8)
		if refreshCursorPos(): Global.Audio.playSFX("cursor")
	elif Global.Inputs.isRepeating("move_right"):
		cursorPosition.x = clamp(cursorPosition.x+1, 0, 8)
		if refreshCursorPos(): Global.Audio.playSFX("cursor")
	elif Global.Inputs.isRepeating("move_up"):
		cursorPosition.y = clamp(cursorPosition.y-1, 0, 8)
		if refreshCursorPos(): Global.Audio.playSFX("cursor")
	elif Global.Inputs.isRepeating("move_down"):
		cursorPosition.y = clamp(cursorPosition.y+1, 0, 8)
		if refreshCursorPos(): Global.Audio.playSFX("cursor")
	#
	if(Input.is_action_just_pressed("action_cancel")):
		Global.Audio.playSFX("cancel")
		parentScreen.setSkillList(true)
	if Input.is_action_just_pressed("action_ok"):
		onUse()

func refreshCursorPos():
	var newPos = Vector2(cursorPosition) * Vector2(16,16) + Vector2(8,8)
	if newPos != cursor.position:
		cursor.position = newPos
		return true
	return false

func onUse():
	var _current = getCurrentSlot()
	if _current != null && _current.currentSkill != null:
		# Show skill to be learned?
		Global.Audio.playSFX("decision")
		skillLearn.setup(self,_current)
	else:
		Global.Audio.playSFX("buzzer")

func getCurrentSlot():
	# Find slot at place
	for s in instancedSlots:
		if s.slot.gridPosition == cursorPosition:
			return s
	return null
