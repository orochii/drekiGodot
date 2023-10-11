@tool
extends Control
class_name SlantedContainer

@export var offset: Vector2 = Vector2(8,64)

func _ready():
	repositionChildren()

func _process(delta):
	repositionChildren()

func repositionChildren():
	var middle = self.get_rect().size / 2
	var count = self.get_child_count()
	var totalSize = (offset * count)
	var startPos = middle - (totalSize / 2)
	var children = self.get_children()
	for i in range(count):
		var child = children[i]
		var half = Vector2()
		if child is Control:
			var c = child as Control
			half = c.get_rect().size / 2
			half.y = 0
			var currPos = startPos + (i * offset) - half
			c.position = currPos
