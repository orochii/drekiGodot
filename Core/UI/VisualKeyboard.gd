extends Control
class_name VisualKeyboard

@export var container:SlantedGridContainer
@export var keyTemplate:PackedScene
@export var keyboardConfig:Array[StringName]
@export var keyboardConfigUpper:Array[StringName]
@export var cursor:AnimatedSprite2D

var keys = []
var keysDups = []
var onKeyPressed:Callable

func _ready():
	cursor.visible = false
	cursor.play(&"default")
	var _size = Vector2(0,0)
	for k in keyboardConfig:
		var prev = null
		if keys.size() != 0: prev = keys[keys.size()-1]
		if keys.size() == 0 || prev.key != k:
			var inst = keyTemplate.instantiate()
			if _size.x==0: _size = Vector2(inst.size.x, inst.size.y)
			inst.setup(k)
			inst.onPress = _onKeyPressed
			container.add_child(inst)
			keys.append(inst)
			keysDups.append(inst)
		else:
			prev.resize(prev.size.x + _size.x)
			keysDups.append(prev)
	# 
	UIUtils.setFluxNeighbors(keys)

func _process(delta):
	if !visible: return
	var focused = get_viewport().gui_get_focus_owner()
	if keys.has(focused):
		cursor.visible = true
		positionCursor(focused)
	else:
		cursor.visible = false

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(2,8)
	else:
		cursor.visible = false

func setFocus():
	keys[0].grab_focus()

func _onKeyPressed(key:StringName):
	onKeyPressed.call(key)

func changeCase(case:bool):
	var conf = keyboardConfigUpper if case else keyboardConfig
	for i in range(conf.size()):
		var k = keysDups[i]
		k.setup(conf[i])
