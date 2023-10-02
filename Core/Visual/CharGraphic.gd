extends Sprite3D

@export var spritesheet : SpritesheetCollection
@export var shadow : Sprite3D
@export var raycast : RayCast3D

var blinkCounter : float = 0
var blinkState : bool = false
var frameCounter : float = 0

func _ready():
	var s = spritesheet.getSheet(&"base")
	blinkCounter = s.blinkRate.x

func _process(delta):
	var s = spritesheet.getSheet(&"base")
	updateFrame(delta, s.fps, s.totalFrames)
	updateBlink(delta, s.blinkRate)
	s.getFrame(self, floori(frameCounter), blinkState)
	if raycast.is_colliding():
		var pos = raycast.get_collision_point()
		shadow.global_position.y = pos.y

func updateFrame(delta, fps : int, totalFrames : int):
	frameCounter += delta*fps
	while (frameCounter >= totalFrames):
		frameCounter -= totalFrames

func updateBlink(delta, blinkRate : Vector2):
	if blinkRate.x > 0:
		blinkCounter -= delta
		if blinkCounter < 0:
			blinkState = !blinkState
			if blinkState:
				blinkCounter = blinkRate.y
			else:
				blinkCounter = blinkRate.x + randf_range(0, 1)
	else:
		blinkCounter = 0
		blinkState = false
