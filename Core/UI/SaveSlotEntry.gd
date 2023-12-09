extends BaseButton

@export var slotImg:NinePatchRect
@export var selected:NinePatchRect
@export var textureSlots:int

var exists = false
var parent = null
var index:int
var filename:String
var _maxIndex:int = 0

func setup(slot:String,idx:int):
	index = idx
	filename = slot
	if Global.saveExist(filename):
		exists = true
		var currIdx = (idx % textureSlots) + 2
		var h_cells = slotImg.texture.get_width() / 24
		slotImg.region_rect.position = Vector2((currIdx%h_cells)*24,(currIdx/h_cells)*24)
	else:
		exists = false
		slotImg.region_rect.position = Vector2(0,0)

func _on_pressed():
	print("Selected: %s" % filename)
	parent.onSlotSelected(filename,exists)

func _on_focus_entered():
	selected.visible = true

func _on_focus_exited():
	selected.visible = false
