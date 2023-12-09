extends Control
class_name SelectPopup

@export var window:Control
@export var container:Container
@export var messageLabel:Label
@export var optionTemplate:PackedScene
@export var cursor:AnimatedSprite2D

var last_focus = null
var onSubmit:Callable
var op = []

func pop(payload:Dictionary):
	last_focus = get_viewport().gui_get_focus_owner()
	var _msg = "?"
	var _opt = null
	if payload.has("message"): _msg = payload["message"]
	if payload.has("options"): _opt = payload["options"]
	setup(_msg, _opt)
	visible = true
	op[0].grab_focus()
	window.size = container.size + Vector2(16,20)

func setup(message:String,options:Array):
	messageLabel.text = message
	if options == null || options.size()==0:
		options = ["Ok"]
	for i in range(options.size()):
		var inst = optionTemplate.instantiate()
		inst.setup(i, options[i])
		inst.action = onSelect
		container.add_child(inst)
		op.append(inst)

func onSelect(index):
	visible = false
	last_focus.grab_focus()
	var payload = {
		"selection" : index
	}
	onSubmit.call(payload)
	for o in op:
		o.queue_free()
	op.clear()

func _process(delta):
	var focused = get_viewport().gui_get_focus_owner()
	if op.has(focused):
		positionCursor(focused)
	else:
		cursor.visible = false

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(2,8)
	else:
		cursor.visible = false
