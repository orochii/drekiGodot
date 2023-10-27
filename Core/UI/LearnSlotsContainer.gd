extends Control
class_name LearnSlotsContainer

const DELAY:float = 0.25
const SHORT:float = 0.05

@export var lineContainer:Control
@export var slotsContainer:Control
@export var learnSlotTemplate:PackedScene
@export var cursor:AnimatedSprite2D
@export var parentScreen:CharacterActionsScreen

var actor:GameActor
var data:Actor
var instancedSlots:Array[LearnSlotEntry]
var instancedEdges:Array[Line2D]
var cursorPosition:Vector2i
var active:bool = false
var moveDelay:float = 0

func _ready():
	cursor.play("default")
	refreshCursorPos()

func setup(_actor:GameActor):
	actor = _actor
	if(actor==null): return
	data = actor.getData()
	if(data==null): return
	#
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
	#
	for i in instancedSlots:
		i.slot.learnings[0].requirements
		var req:BaseSkill = i.slot.learnings[0].skill
		for j in instancedSlots:
			if j.slot.learnings[0].requirements.has(req):
				var srcPos = i.position + Vector2(8,8)
				var dstPos = j.position + Vector2(8,8)
				var line = Line2D.new()
				line.add_point(srcPos)
				line.add_point(Vector2(srcPos.x,dstPos.y))
				line.add_point(dstPos)
				line.width = 1
				lineContainer.add_child(line)
				instancedEdges.append(line)
	# active = true

func _process(delta):
	if(!self.is_visible_in_tree()): return
	if moveDelay > 0:
		moveDelay -= delta
	if active:
		cursor.visible = true
		# <>
		if(Input.is_action_pressed("move_left")):
			if moveDelay > 0 && !Input.is_action_just_pressed("move_left"): return
			cursorPosition.x = clamp(cursorPosition.x-1, 0, 8)
			if refreshCursorPos(): Global.Audio.playSFX("cursor")
			moveDelay = DELAY if Input.is_action_just_pressed("move_left") else SHORT
		elif(Input.is_action_pressed("move_right")):
			if moveDelay > 0 && !Input.is_action_just_pressed("move_right"): return
			cursorPosition.x = clamp(cursorPosition.x+1, 0, 8)
			if refreshCursorPos(): Global.Audio.playSFX("cursor")
			moveDelay = DELAY if Input.is_action_just_pressed("move_right") else SHORT
		elif(Input.is_action_pressed("move_up")):
			if moveDelay > 0 && !Input.is_action_just_pressed("move_up"): return
			cursorPosition.y = clamp(cursorPosition.y-1, 0, 8)
			if refreshCursorPos(): Global.Audio.playSFX("cursor")
			moveDelay = DELAY if Input.is_action_just_pressed("move_up") else SHORT
		elif(Input.is_action_pressed("move_down")):
			if moveDelay > 0 && !Input.is_action_just_pressed("move_down"): return
			cursorPosition.y = clamp(cursorPosition.y+1, 0, 8)
			if refreshCursorPos(): Global.Audio.playSFX("cursor")
			moveDelay = DELAY if Input.is_action_just_pressed("move_down") else SHORT
		else:
			moveDelay = 0
		#
		if(Input.is_action_just_pressed("action_cancel")):
			Global.Audio.playSFX("cancel")
			parentScreen.setSkillList(true)
	else:
		cursor.visible = false

func refreshCursorPos():
	var newPos = Vector2(cursorPosition) * Vector2(16,16) + Vector2(8,8)
	if newPos != cursor.position:
		cursor.position = newPos
		return true
	return false
