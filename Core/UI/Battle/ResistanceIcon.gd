extends NinePatchRect
class_name ResistanceIcon

@export var iconSprite:NinePatchRect
@export var affinityIcons:Array[Texture2D]
@export var elementIcons:Array[Texture2D]
@export var colors:Array[Color]

func setup(icon:Texture2D, ary:Array):
	# Set icon
	iconSprite.texture = icon
	var originalValue = ary[0]
	var changedValue = ary[1]
	# Set affinity
	if changedValue <= 0: 
		texture = affinityIcons[1]
	elif changedValue < 1: 
		texture = affinityIcons[0]
	else: 
		texture = affinityIcons[2]
	# Set changed by state basically
	if originalValue < changedValue:
		iconSprite.modulate = colors[0]
	elif originalValue > changedValue:
		iconSprite.modulate = colors[2]
	else:
		iconSprite.modulate = colors[1]
