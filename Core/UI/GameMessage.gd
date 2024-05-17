extends NinePatchRect
class_name GameMessage

const CLAMP_MARGIN = 16
const POS_MARGIN = 32

@export var messageText : RichTextLabel
@export var speakerText : RichTextLabel
@export var container : Container
@export var messageSpeed : float = 20.0
@export var textMarginTop : float = 4
@export var textMarginBottom : float = 8
@export var textMarginLeft : float = 4
@export var textMarginRight : float = 4
@export var tailSprite : Sprite2D
@export var optionTemplate : PackedScene
@export var cursor:AnimatedSprite2D

var textBoxPosition = 8

signal onMessageReady()
signal onMessageEnd()

var targetPosition : Node3D
var visibleChars : float = 0
var totalChars : int = 0
var options : Array = []
var optionsVarId : StringName = &""
var optionsCancelIdx : int = -1

func _ready():
	visible = false

func setOptions(varId:StringName, optionsList:Array, cancelOption:int=-1):
	optionsVarId = varId
	optionsCancelIdx = cancelOption
	for i in range(optionsList.size()):
		var inst = optionTemplate.instantiate()
		inst.setup(i, optionsList[i])
		container.add_child(inst)
		options.append(inst)
	UIUtils.setVNeighbors(options)

func showText(targetNode:Node3D, textPos:int, speaker:String, message:String):
	await onMessageReady
	targetPosition = targetNode
	textBoxPosition = textPos
	messageText.visible_characters = 0
	visibleChars = 0
	speakerText.text = TextUtils.parseText(TranslationServer.translate(speaker))
	messageText.text = TextUtils.parseText(TranslationServer.translate(message))
	totalChars = messageText.get_total_character_count()
	resizeWindow()
	refreshPosition()
	visible = true
	await onMessageEnd

func _process(delta):
	if visible:
		refreshPosition()
		
		var focused = get_viewport().gui_get_focus_owner()
		if options.has(focused):
			positionCursor(focused)
		else:
			cursor.visible = false
		
		if visibleChars < totalChars:
			messageText.visible_characters = roundi(visibleChars)
			visibleChars += delta * messageSpeed
			if visibleChars > totalChars:
				visibleChars = totalChars
				messageText.visible_characters = roundi(visibleChars)
				if options.size() != 0:
						options[0].grab_focus()
		var _closeAction = 0
		if Input.is_action_just_pressed("action_ok"): _closeAction = 1
		if Input.is_action_just_pressed("action_cancel"): _closeAction = 2
		if _closeAction != 0:
			if visibleChars == totalChars:
				var shouldClose = false
				if _closeAction==1:
					if options.size() != 0:
						if options.has(focused):
							# set variable
							var val = options.find(focused)
							Global.State.setVariable(optionsVarId, val)
					shouldClose = true
					Global.Audio.playSFX("decision")
				if _closeAction==2:
					if options.size() != 0:
						if optionsCancelIdx != -1:
							# set variable
							Global.State.setVariable(optionsVarId, optionsCancelIdx)
							shouldClose = true
							Global.Audio.playSFX("cancel")
				if shouldClose:
					visible = false
					onMessageEnd.emit()
					for o in options:
						o.queue_free()
					options.clear()
			else:
				visibleChars = totalChars
				messageText.visible_characters = roundi(visibleChars)
				if options.size() != 0:
					options[0].grab_focus()
	else:
		onMessageReady.emit()

func busy():
	return visible

func resizeWindow():
	container.position = Vector2(textMarginLeft, textMarginTop)
	container.update_minimum_size()
	container.size = container.get_minimum_size()
	self.size = (container.get_minimum_size() + container.position + Vector2(textMarginRight,textMarginBottom))
	#self.size = container.get_minimum_size()

func refreshPosition():
	if targetPosition != null:
		repositionAroundRefNode()
	else:
		repositionAroundScreen()

func repositionAroundRefNode():
	var screenSize = Global.UI.screenSize()
	var pos = Global.UI.posToScreen(targetPosition.global_position)
	var boxSize = self.size
	var horzDir = getHorzDir(textBoxPosition)
	var vertDir = getVertDir(textBoxPosition)
	
	var posMargin = 4
	var nodeW = 12
	var nodeH = 32
	
	if pos.x < boxSize.x:
		horzDir = 1
	elif pos.x >= screenSize.x - boxSize.x:
		horzDir = -1
	
	if pos.y < boxSize.y:
		vertDir = 1
	elif pos.y >= screenSize.y - boxSize.y:
		vertDir = -1
	
	var targetPos = pos
	var dir = 8
	match vertDir:
		-1:
			targetPos += Vector2(-boxSize.x/2, -boxSize.y - nodeH - posMargin)
			dir = 8
		1:
			targetPos += Vector2(-boxSize.x/2, posMargin)
			dir = 2
		_:
			match horzDir:
				-1:
					targetPos += Vector2(-boxSize.x - nodeW - posMargin, -boxSize.y/2 - nodeH/2)
					dir = 4
				_:
					targetPos += Vector2(posMargin + nodeW, -boxSize.y/2 - nodeH/2)
					dir = 6
	targetPos.x = clampf(targetPos.x, CLAMP_MARGIN, screenSize.x - CLAMP_MARGIN - boxSize.x)
	targetPos.y = clampf(targetPos.y, CLAMP_MARGIN, screenSize.y - CLAMP_MARGIN - boxSize.y)
	placeTail(dir,pos,targetPos,boxSize,nodeH)
	self.global_position = targetPos

func repositionAroundScreen():
	tailSprite.visible = false
	var screenSize = Global.UI.screenSize()
	var boxSize = self.size
	match textBoxPosition:
		1:	# BOTTOM_LEFT
			self.global_position = Vector2(POS_MARGIN, screenSize.y - boxSize.y - POS_MARGIN)
		2:	# BOTTOM
			self.global_position = Vector2((screenSize.x - boxSize.x) / 2, screenSize.y - boxSize.y - POS_MARGIN)
		3:	# BOTTOM RIGHT
			self.global_position = Vector2(screenSize.x - boxSize.x - POS_MARGIN, screenSize.y - boxSize.y - POS_MARGIN)
		4:	# LEFT
			self.global_position = Vector2(POS_MARGIN, (screenSize.y - boxSize.y) / 2)
		6:	# RIGHT
			self.global_position = Vector2(screenSize.x - boxSize.x - POS_MARGIN, (screenSize.y - boxSize.y) / 2)
		7:	# TOP LEFT
			self.global_position = Vector2(POS_MARGIN, POS_MARGIN)
		8:	# TOP
			self.global_position = Vector2((screenSize.x - boxSize.x) / 2, POS_MARGIN)
		9:	# TOP RIGHT
			self.global_position = Vector2(screenSize.x - boxSize.x - POS_MARGIN, POS_MARGIN)
		_:	# CENTER
			self.global_position = (screenSize - boxSize) / 2

func getHorzDir(d) -> int:
	match d:
		1,4,7:
			return -1
		3,6,9:
			return 1
		_:
			return 0

func getVertDir(d) -> int:
	match d:
		1,2,3:
			return 1
		7,8,9:
			return -1
		_:
			return 0

func placeTail(dir,pos,targetPos,boxSize,nodeH):
	match dir:
		2: # DOWN, put tail up
			var min = targetPos.x + 4
			var max = targetPos.x + boxSize.x - 4
			var tx = clamp(pos.x, min, max)
			var ty = targetPos.y - 3 #DONE
			tailSprite.global_position = Vector2(tx,ty)
			tailSprite.rotation_degrees = 0
			tailSprite.flip_h = false
			tailSprite.flip_v = true
		4: # LEFT, put tail right
			var tx = targetPos.x + boxSize.x + 3 #DONE
			var min = targetPos.y + 4
			var max = targetPos.y + boxSize.y - 4
			var ty = clamp(pos.y - nodeH/2, min, max)
			tailSprite.global_position = Vector2(tx,ty)
			tailSprite.rotation_degrees = 90
			tailSprite.flip_h = false
			tailSprite.flip_v = true
		6: # RIGHT, put tail left
			var tx = targetPos.x - 3 #DONE
			var min = targetPos.y + 4
			var max = targetPos.y + boxSize.y - 4
			var ty = clamp(pos.y - nodeH/2, min, max)
			tailSprite.global_position = Vector2(tx,ty)
			tailSprite.rotation_degrees = 90
			tailSprite.flip_h = false
			tailSprite.flip_v = false
		8: # UP, put tail down
			var min = targetPos.x + 4
			var max = targetPos.x + boxSize.x - 4
			var tx = clamp(pos.x, min, max)
			var ty = targetPos.y + boxSize.y + 3 #DONE
			tailSprite.global_position = Vector2(tx,ty)
			tailSprite.rotation_degrees = 0
			tailSprite.flip_h = false
			tailSprite.flip_v = false

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(2,8)
	else:
		cursor.visible = false
