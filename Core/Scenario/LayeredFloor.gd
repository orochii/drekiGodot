extends MeshInstance3D

var allVisuals : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	getAllVisuals()
	for n:VisualInstance3D in allVisuals:
		n.layers = layers

func getAllVisuals():
	allVisuals.clear()
	getChildren(self)
func getChildren(root:Node):
	var cs = root.get_children(true)
	for c in cs:
		if c is VisualInstance3D:
			allVisuals.append(c)
		getChildren(c)
