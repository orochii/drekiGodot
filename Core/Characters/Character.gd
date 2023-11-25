extends CharacterBody3D
class_name Character

const JUMP : float = 24
const AVG_SPEED : float = 15
const GRAVITY : float = 98*2

@export var speed = AVG_SPEED
@export var speedMult = 1
@export var graphic : CharGraphic
@export var collider: CollisionShape3D
@export var state : StringName = &"base"
@export var raycast : RayCast3D
@export var soundEmitter : AudioStreamPlayer3D
@export var stepEventOverride : StringName = &""

var forcedMove = false
var lastGroundedPosition = Vector3.ZERO
var target_velocity = Vector3.ZERO
var grounded : bool = false
var collision : bool = true

func _ready():
	lastGroundedPosition = global_position
	if graphic != null: graphic.onFrame.connect(playStep)

func setMove(direction : Vector3):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		look_at(position - direction, Vector3.UP)
	var mspeed = speed * getSpeedMult()
	target_velocity.x = direction.x * mspeed
	target_velocity.z = direction.z * mspeed

func jump():
	if is_on_floor():
		target_velocity.y = JUMP
		playJump()

func _physics_process(delta):
	if forcedMove:
		return
	
	grounded = is_on_floor()
	if not grounded: # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (GRAVITY * delta)
	else:
		if target_velocity.y < 0: target_velocity.y = 0
	velocity = target_velocity
	if graphic != null:
		graphic.speed = velocity.length() / AVG_SPEED
		graphic.state = getCurrentState()
	if(raycast != null):
		# filter out any positions with weird elevations (up to a certain degree)
		var c = raycast.get_collider()
		if c != null:
			var n = raycast.get_collision_normal()
			var deg = rad_to_deg(n.angle_to(Vector3.UP))
			print("floorAngle:%f" % deg)
			if deg < 45.0:
				lastGroundedPosition = global_position
	#		var mesh:MeshInstance3D = c.get_parent()
	#		#mesh.material
	move_and_slide()

func playJump():
	var audio:AudioManager = Global.Audio
	var _ev = audio.audioData.getEvent("jump")
	if(_ev==null): return
	soundEmitter.stream = _ev.getSample()
	soundEmitter.play()

func playStep(ev:StringName, idx:int):
	if(ev != &"step"): return
	if(!grounded): return
	if(soundEmitter != null):
		var audio:AudioManager = Global.Audio
		if stepEventOverride.length() != 0:
			var _ev = audio.audioData.getEvent(stepEventOverride)
		else:
			var _ev = audio.audioData.getEvent(&"step")
			soundEmitter.stream = _ev.getSample()
			soundEmitter.play()

func getCurrentState():
	if state == &"base":
		if !grounded:
			return &"jump"
		if graphic.speed >= 1.1:
			return &"run"
	return state

func getSpeedMult():
	return speedMult

func setCollision(v:bool):
	collision = v
	if v:
		self.collision_layer = 1
		self.collision_mask = 1
	else:
		self.collision_layer = 2
		self.collision_mask = 2
	#collider.disabled = !v
	if collision==false: target_velocity.y = 0
