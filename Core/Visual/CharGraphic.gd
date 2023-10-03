extends Sprite3D
class_name CharGraphic

@export var spritesheet : Spritesheet
@export var shadow : Sprite3D
@export var raycast : RayCast3D
@export var blinkRate = Vector2(2.5, 0.2)

var speed : float = 1
var blinkCounter : float = 0
var blinkState : bool = false
var frameCounter : float = 0

func _ready():
	blinkCounter = blinkRate.x

func _process(delta):
	var dts = delta * speed
	updateFrame(dts)
	updateBlink(dts)
	if raycast.is_colliding():
		var pos = raycast.get_collision_point()
		shadow.global_position.y = pos.y
		var size = 1 - (shadow.position.y / raycast.target_position.y)
		shadow.scale = Vector3.ONE * size

func updateFrame(delta):
	if spritesheet != null:
		var s = spritesheet.getSheet(&"base")
		if s != null:
			updateFrameCounter(delta, s.fps, s.getTotalFrames())
			s.getFrame(self, floori(frameCounter), blinkState)
	else:
		texture = null

func updateFrameCounter(delta, fps : int, totalFrames : int):
	if speed == 0:
		frameCounter = 0
	else:
		frameCounter += delta*fps
		while (frameCounter >= totalFrames):
			frameCounter -= totalFrames

func updateBlink(delta):
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
