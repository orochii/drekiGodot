extends Button

@export var nameLabel:Label

var parent = null
var folder:String = ""

func setup(n:String):
	folder = n
	if folder == "":
		nameLabel.text = "<New file>"
	else:
		nameLabel.text = n


func _on_pressed():
	parent.onFileSelected(folder)
