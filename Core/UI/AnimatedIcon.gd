extends NinePatchRect

@export var frames : Array[Vector2i]
@export var frameSize : Vector2i
@export var frameRate : int = 4
var frameIdx = 0
var delay = 0

func _ready():
	_updateFrame()

func _process(delta):
	delay += delta * frameRate
	if delay > 1:
		var i = floori(delay)
		frameIdx = (frameIdx + i) % frames.size()
		delay -= i
		_updateFrame()

func _updateFrame():
	var currFrame = frames[frameIdx]
	var pos = currFrame * frameSize
	self.region_rect.position = Vector2(pos.x, pos.y)
	self.region_rect.size = Vector2(frameSize.x, frameSize.y)
