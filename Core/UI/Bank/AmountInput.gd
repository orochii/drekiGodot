@tool
extends HBoxContainer

@export_group("Behavior")
@export var currentNumber : int
@export var currentMax : int = 99999
@export var cursorIdx : int
@export var dir : int
@export var editing : bool
@export_group("Setup")
@export var numbers : Array[RollingNumber]
@export var container : Control
@export var cursor : Control
@export var arrowUp : NinePatchRect
@export var arrowDown : NinePatchRect

func move(d:int):
	cursorIdx = (cursorIdx + d + numbers.size()) % numbers.size()
func change(d:int):
	var a = d * pow(10,numbers.size()-cursorIdx-1)
	var _max = pow(10, numbers.size()) - 1
	var _realMax = mini(_max, currentMax)
	var newNumber = currentNumber + a
	currentNumber = clampi(newNumber, 0, _realMax)
	#
	print("a:%d _max:%d realMax:%d newNumber:%d current:%d" % [a,_max,_realMax,newNumber,currentNumber])

func _process(delta):
	if container != null: container.custom_minimum_size.x = (numbers.size() * 10) + 8
	if cursor != null:
		if editing:
			cursorIdx = clampi(cursorIdx, 0, numbers.size() - 1)
			cursor.position = Vector2(cursorIdx*10, 0)
			cursor.visible = true
			match dir:
				1:
					arrowUp.region_rect.position.x = 16
					arrowDown.region_rect.position.x = 0
				-1:
					arrowUp.region_rect.position.x = 0
					arrowDown.region_rect.position.x = 16
				_:
					arrowUp.region_rect.position.x = 0
					arrowDown.region_rect.position.x = 0
		else:
			cursor.visible = false
	# check for min/max
	var _max = pow(10, numbers.size()) - 1
	currentNumber = clampi(currentNumber, 0, mini(_max, currentMax))
	# refresh number
	var _c = currentNumber
	for i in range(numbers.size()-1, -1, -1):
		var n = numbers[i]
		var _u = _c % 10
		n.currentNumber = _u
		_c = _c / 10
