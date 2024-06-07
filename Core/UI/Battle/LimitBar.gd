@tool
extends HBoxContainer
class_name LimitBar

@export var limitBar:ColorRect
@export_range(0.0,1.0) var currentValue:float = 1.0

var _full:bool = false
var _spent:bool = false

func _process(delta):
	limitBar.anchor_right = currentValue
	var m = limitBar.material as ShaderMaterial
	if isFull():
		m.set_shader_parameter("strength", 1)
		if _full == false:
			_full = true
			Global.UI.onLimitChange.emit()
	else:
		m.set_shader_parameter("strength", 0)
		if _full == true:
			_full = false
			Global.UI.onLimitChange.emit()
	if isSpent():
		m.set_shader_parameter("overlay", 1)
	else:
		m.set_shader_parameter("overlay", 0)

func spend():
	_spent = true
func isSpent():
	return _spent

func flush():
	currentValue = 0.0
	_spent = false
	_full = false
	Global.UI.onLimitChange.emit()
func isFull():
	return currentValue >= 1.0
