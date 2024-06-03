extends Control

@export var anchorRef : Control
@export var openOffset : Vector2i
@export var closedOffset : Vector2i
@export var lines : Array[HUDPartyHealthLine]

var state:bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_connectToUI()
	var lineOffset = openOffset if state else closedOffset
	var totalHeight = Global.State.party.getMembers().size() * lineOffset.y
	for l in lines.size():
		lines[l].refresh(l)
		#
		var currOffset = Vector2(lineOffset.x, (lineOffset.y * l) - totalHeight)
		lines[l].targetPos = currOffset
		lines[l].position = anchorRef.position + lines[l].targetPos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var moveSpeed = delta*480
	if Input.is_action_just_pressed("action_select"):
		state = !state
	
	var lineOffset = openOffset if state else closedOffset
	var totalHeight = Global.State.party.getMembers().size() * lineOffset.y
	for l in lines.size():
		lines[l].refresh(l)
		#
		var currOffset = Vector2(lineOffset.x, (lineOffset.y * l) - totalHeight)
		lines[l].targetPos = lines[l].targetPos.move_toward(currOffset, moveSpeed)
		lines[l].position = anchorRef.position + lines[l].targetPos

func _connectToUI():
	if !Global.UI.onHpChange.is_connected(_onHpChange):
		Global.UI.onHpChange.connect(_onHpChange)

func _disconnectToUI():
	if Global.UI.onHpChange.is_connected(_onHpChange):
		Global.UI.onHpChange.disconnect(_onHpChange)

func _onHpChange(b,max):
	for l in lines:
		if l._actor==b: l.refreshHP()

func _exit_tree():
	_disconnectToUI()
