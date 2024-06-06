extends Control
class_name BaseWindow

@export var cursor:AnimatedSprite2D
@export var cursorOffset:Vector2 = Vector2(10,8)

func _ready():
    if cursor != null: cursor.play("default")

func repositionCursor(focused):
    if cursor != null: 
        if focused != null:
            cursor.global_position = focused.global_position + cursorOffset
            cursor.visible = true
        else:
            cursor.visible = false
