extends Node

@export var targetNodePath:NodePath
@export var speed:float
@export var positions:Array[Vector3]
@export var sound:AudioStreamPlayer3D

var currentIdx:int
var targetNode:Node3D

func _ready():
	targetNode = get_node(targetNodePath)
	positions.append(targetNode.position)
	currentIdx = -1

func _process(delta):
	var currPos = positions[currentIdx]
	if currPos != targetNode.position:
		targetNode.position = targetNode.position.move_toward(currPos, delta*speed)

func move():
	currentIdx = (currentIdx+1) % positions.size()
	if sound != null: sound.play()

func moveTo(idx,immediate=false):
	if targetNode==null: resolveTarget()
	currentIdx = idx
	if immediate:
		var currPos = positions[currentIdx]
		targetNode.position = currPos
	else:
		if sound != null: sound.play()

func resolveTarget():
	targetNode = get_node(targetNodePath)
