extends Button

@export var positionLabel:Label
@export var positionGraphic:NinePatchRect
@export var leftArrow:Label
@export var rightArrow:Label

func _process(delta):
    var focused = get_viewport().gui_get_focus_owner()
    setFocused(focused == self)

func setPosition(_pos:int):
    match _pos:
        0:
            positionLabel.text = "Front"
            positionGraphic.region_rect.position.y = 0
        1:
            positionLabel.text = "Back"
            positionGraphic.region_rect.position.y = 32

func setFocused(v:bool):
    var _c = Color.WHITE if v else Color.TRANSPARENT
    leftArrow.self_modulate = _c
    rightArrow.self_modulate = _c