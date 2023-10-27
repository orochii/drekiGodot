extends Button
class_name BaseOption

@export var label:Label

var category:StringName
var _inst:Object
var _property:StringName
var _getter:Callable
var _setter:Callable
var onValueChange:Callable
var _parent = null
var active:bool = false

func setVariable(inst:Object, property:StringName):
	_inst = inst
	_property = property
func setCallables(getter,setter):
	_inst = null
	_getter = getter
	_setter = setter

func getValue():
	if(_inst==null):
		return _getter.call()
	else:
		return _inst.get(_property)

func setValue(v):
	if(_inst==null):
		_setter.call(v)
	else:
		_inst.set(_property,v)
		if !onValueChange.is_null(): onValueChange.call()

func getHelp():
	return label.text + "_help"

func _on_pressed():
	setActive(true)

func setActive(v:bool):
	# Set focus to none (?)
	if v: onActive()
	else: 
		onInactive()
		self.grab_focus()
	# Stop everything else from responding or something
	_parent.active = !v
	# Activate this node's uh thing.
	active = v

func onActive():
	pass
func onInactive():
	pass
func onVisible():
	pass
