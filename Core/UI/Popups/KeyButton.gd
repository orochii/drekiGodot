extends TextureButton

@export var btnTexture:NinePatchRect
@export var label:Label

var key:StringName
var onPress:Callable

func setup(k:StringName):
	key = k
	label.text = k

func resize(newSize):
	size.x = newSize
	label.size.x = newSize
	btnTexture.size.x = newSize

func _on_pressed():
	if onPress != null:
		onPress.call(key)
