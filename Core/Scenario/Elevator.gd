extends Node3D

@export var speed:float
@export var positions:Array[Vector3]

var currentIdx:int

func _ready():
	positions.append(position)
	currentIdx = -1

func _process(delta):
	var currPos = positions[currentIdx]
	if currPos != position:
		position = position.move_toward(currPos, delta*speed);

func move():
	currentIdx = (currentIdx+1) % positions.size()

func moveTo(idx,immediate=false):
	currentIdx = idx
	if immediate:
		var currPos = positions[currentIdx]
		position = currPos
