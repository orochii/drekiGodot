extends Control
class_name SelectPopup

@export var window:Control
@export var container:Container
@export var messageLabel:Label
@export var optionTemplate:PackedScene

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
