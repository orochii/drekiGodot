@icon("res://Editor/character.svg")
extends CharacterBody3D
class_name Character

const JUMP : float = 24
const AVG_SPEED : float = 15
const GRAVITY : float = 98*2

@export var speed = AVG_SPEED
@export var speedMult = 1
@export var graphic : CharGraphic
@export var collider : CollisionShape3D
@export var navigator : NavigationAgent3D
@export var state : StringName = &"base"
@export var raycast : RayCast3D
@export var soundEmitter : Node3D
@export var stepEventOverride : StringName = &""
@export var fixedDirection : bool
@export var balloon:Sprite3D
@export var balloonAnim:AnimationPlayer
@export var canRespawn : bool = true
@export var charLayer:int = 1

var forcedMove = false
var navigating = false
var lastGroundedCollider = null
var lastGroundedPosition = Vector3.ZERO
var target_velocity = Vector3.ZERO
var grounded : bool = false
var collision : bool = true
var erased : bool = false

func setLayer(i:int):
	charLayer = i
	var l = int(pow(2, i-1))
	if graphic != null: graphic.setLayer(l)
	if balloon != null: balloon.layers = l

# TO TEST!
func stopNavigate():
	navigating = false
	target_velocity.x = 0
	target_velocity.z = 0

func navigateTowards(pos:Vector3):
	if navigator==null: return
	navigating = true
	navigator.target_position = pos
	if !navigator.is_target_reachable():
		navigating = false
		target_velocity.x = 0
		target_velocity.z = 0

func setErased(v:bool):
	erased = v
	visible = !v
	if erased:
		process_mode = Node.PROCESS_MODE_DISABLED
	else:
		process_mode = Node.PROCESS_MODE_INHERIT

func getLastGroundedPosition():
	if (lastGroundedCollider != null):
		return lastGroundedCollider.global_position + lastGroundedPosition
	return lastGroundedPosition

func _ready():
	setLayer(charLayer)
	setCollision(true)
	lastGroundedPosition = global_position
	if graphic != null: 
		graphic.onFrame.connect(playStep)
		if balloon != null: 
			balloon.offset = Vector2(0, graphic.getScreenSize().y + 8)

func showBalloon(name:StringName):
	balloonAnim.play(name)

func setMove(direction : Vector3):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		if !fixedDirection: lookTowards(global_position + direction)
	var mspeed = speed * getSpeedMult()
	target_velocity.x = direction.x * mspeed
	target_velocity.z = direction.z * mspeed

func lookTowards(pos):
	var d:Vector3 = pos - global_position
	var a = d.signed_angle_to(Vector3.BACK,Vector3.UP)
	global_rotation = Vector3(0,-a,0)

func jump():
	if is_on_floor():
		target_velocity.y = JUMP
		playJump()

func _physics_process(delta):
	if forcedMove:
		return
	
	if navigating:
		var navDir = (navigator.get_next_path_position()-global_position).normalized()
		var mspeed = speed * getSpeedMult()
		target_velocity.x = navDir.x * mspeed
		target_velocity.z = navDir.z * mspeed
		if navDir != Vector3.ZERO:
			if !fixedDirection: lookTowards(global_position + navDir)
		move_and_slide()
		var dst = navigator.get_final_position().distance_to(global_position) < 0.5
		if navigator.is_target_reachable()==false || dst:
			target_velocity.x = 0
			target_velocity.z = 0
			navigating = false
	
	grounded = is_on_floor()
	if not grounded: # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (GRAVITY * delta)
	else:
		if target_velocity.y < 0: target_velocity.y = 0
	#if !collision: target_velocity.y = 0
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
			if deg < 45.0:
				lastGroundedCollider = c
				lastGroundedPosition = global_position - c.global_position
	#		var mesh:MeshInstance3D = c.get_parent()
	#		#mesh.material
	move_and_slide()

func playJump():
	var audio:AudioManager = Global.Audio
	var _ev = audio.audioData.getEvent("jump")
	if(_ev==null): return
	playSound(_ev.getSample())

func playStep(ev:StringName, idx:int):
	if(ev != &"step"): return
	if(!grounded): return
	if(soundEmitter != null):
		if Global.Config.stepSounds != true: return
		var audio:AudioManager = Global.Audio
		if stepEventOverride.length() != 0:
			var _ev = audio.audioData.getEvent(stepEventOverride)
		else:
			var _ev = audio.audioData.getEvent(&"step")
			playSound(_ev.getSample())

var _currStreamIdx:int = 0

func playSound(stream:AudioStream):
	if soundEmitter is AudioStreamPlayer3D:
		soundEmitter.stream = stream
		soundEmitter.play()
	else:
		var emitter = soundEmitter.get_child(_currStreamIdx)
		emitter.stream = stream
		emitter.play()
		_currStreamIdx = (_currStreamIdx+1) % soundEmitter.get_child_count()

func getCurrentState():
	if state == &"base":
		if !grounded:
			return &"jump"
		if graphic.speed >= 1.1:
			return &"run"
	return state

func getSpeedMult():
	return speedMult

const COLL_LAYER_WORLD = 1+4
const COLL_LAYER_OBJECTS = 2

func setCollision(v:bool):
	collision = v
	if v:
		self.collision_layer = COLL_LAYER_OBJECTS
		self.collision_mask = COLL_LAYER_WORLD+COLL_LAYER_OBJECTS
	else:
		self.collision_layer = 0
		self.collision_mask = COLL_LAYER_WORLD
	#collider.disabled = !v
	if collision==false: target_velocity.y = 0
