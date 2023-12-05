extends Button

@export var slotImg:NinePatchRect
@export var slotTextures:Array[Texture]

var exists = false
var parent = null
var index:int
var filename:String

func setup(slot:String,idx:int):
	index = idx
	filename = slot
	if Global.saveExist(filename):
		exists = true
		slotImg.texture = slotTextures[idx % slotTextures.size()]
	else:
		exists = false
		slotImg.texture = null

func _on_pressed():
	print("Selected: %s" % filename)
	parent.onSlotSelected(filename,exists)
