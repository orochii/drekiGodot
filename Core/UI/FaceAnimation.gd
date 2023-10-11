extends NinePatchRect

const FPS = 8

var active : bool = false
var frame : float = 0
var blinkState : bool = false
var blinkTimer : float = 0.0

func _ready():
	blinkTimer = getBlinkOffTime()

func _process(delta):
	updateFrame(delta)
	updateBlink(delta)
	updateRegion()

func updateFrame(delta):
	if active:
		frame = move_toward(frame, 2, delta * FPS)
	else:
		frame = move_toward(frame, 0, delta * FPS)

func updateBlink(delta):
	blinkTimer -= delta
	if blinkTimer <= 0:
		blinkState = !blinkState
		if blinkState:
			blinkTimer = getBlinkOnTime()
		else:
			blinkTimer = getBlinkOffTime()

func updateRegion():
	match floori(frame):
		0:
			region_rect.position.x = 0
			if (blinkState): region_rect.position.x += 48
		2:
			region_rect.position.x = 144
			if (blinkState): region_rect.position.x += 48
		_:
			region_rect.position.x = 96

func getBlinkOffTime():
	return 2 + randf_range(0,0.5)
func getBlinkOnTime():
	return 0.1
