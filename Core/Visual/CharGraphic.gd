extends Sprite3D
class_name CharGraphic

signal onFrame(ev:StringName, idx:int)
signal onLoop(_state:StringName)

@export var spritesheet : Spritesheet
@export var state : StringName = &"base"
@export var shadow : Sprite3D
@export var raycast : RayCast3D
@export var blinkRate = Vector2(2.5, 0.2)

var speed : float = 1
var blinkCounter : float = 0
var blinkState : bool = false
var frameCounter : float = 0
var lastFrame : int = -1

func _ready():
	blinkCounter = blinkRate.x

func _process(delta):
	var dts = delta * speed
	updateFrame(dts,delta)
	updateBlink(delta)
	if(raycast != null):
		if raycast.is_colliding():
			var pos = raycast.get_collision_point()
			shadow.global_position.y = pos.y
			var size = 1 - (shadow.position.y / raycast.target_position.y)
			shadow.scale = Vector3.ONE * size

func getCurrentSheet():
	if speed==0 && hasIdle():
		return spritesheet.getSheet(state+"_idle")
	return spritesheet.getSheet(state)
func updateFrame(delta,deltaUnscaled):
	updateAngleDeform()
	if spritesheet != null:
		var _lastState = state
		var s:SpritesheetEntry = getCurrentSheet()
		if s != null:
			if speed==0:
				var dd = deltaUnscaled * s.idleSpeed
				if dd == 0:
					frameCounter = 0
				else:
					updateFrameCounter(dd, s.fps, s.getTotalFrames())
			else:
				updateFrameCounter(delta, s.fps, s.getTotalFrames())
		# uh... yeah, a weird workaround for switching states before loop
		if _lastState != state:
			s = getCurrentSheet()
		if s != null:
			var newFrame = floori(frameCounter)
			s.getFrame(self, newFrame, blinkState)
			if(lastFrame != newFrame):
				# emit frame change if spritesheet says so
				var ev:StringName = s.getFrameEvent(newFrame)
				onFrame.emit(ev,newFrame)
			lastFrame = newFrame
	else:
		texture = null

func updateAngleDeform():
	var cam = get_viewport().get_camera_3d()
	if (cam != null):
		var r = cam.global_rotation.x
		var c = abs(cos(r))
		if (c < 0.01): c = 0.01
		self.scale.y = 1 / c
	else:
		self.scale.y = 1

func hasIdle():
	return spritesheet.getSheet(state+"_idle") != null

func setNewState(stateName):
	state = stateName
	frameCounter = 0

func updateFrameCounter(delta, fps : int, totalFrames : int):
	if speed == 0 && !hasIdle():
		frameCounter = 0
	else:
		frameCounter += delta*fps
		while (frameCounter >= totalFrames):
			frameCounter -= totalFrames
			onLoop.emit(state)

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

func getScreenSize() -> Vector2:
	return region_rect.size
func getSize() -> Vector2:
	return getScreenSize() * pixel_size
