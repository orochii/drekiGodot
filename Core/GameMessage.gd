extends NinePatchRect
class_name GameMessage

@export var text : RichTextLabel
@export var messageSpeed : float = 20.0

signal onMessageReady()
signal onMessageEnd()

var visibleChars : float = 0
var totalChars : int = 0

func _ready():
	visible = false

func showText(message:String):
	await onMessageReady
	text.visible_characters = 0
	visibleChars = 0
	totalChars = text.get_total_character_count()
	text.text = message
	visible = true
	await onMessageEnd

func _process(delta):
	if visible:
		text.visible_characters = roundi(visibleChars)
		visibleChars += delta * messageSpeed
		if visibleChars > totalChars:
			visibleChars = totalChars
		if Input.is_action_just_pressed("action_ok"):
			if visibleChars == totalChars:
				visible = false
				onMessageEnd.emit()
			else:
				visibleChars = totalChars
	else:
		onMessageReady.emit()

func busy():
	return visible
