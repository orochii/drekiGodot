extends CharacterBody3D
class_name Vehicle

@export var requireItem:BaseItem = null
@export var mountedCharacter:Character = null
@export var attachPoint:Node3D = null
@export var moveSpeed:float = 3
@export var rotateSpeed:float = 60
@export var bodyExceptions:Array[PhysicsBody3D]
@export var startEngine:AudioStreamPlayer3D
@export var endEngine:AudioStreamPlayer3D
@export var ui:Control
@export var interactOffset:float = 2.0
var lastForward = 0
var lastRotate = 0

func onInteract():
	if requireItem != null:
		if !Global.State.party.hasItem(requireItem.getId()):
			return
	mount(Global.Player)
func mount(character:Character):
	character.graphic.speed = 0
	character.forcedMove = true
	startEngine.pitch_scale = 1
	startEngine.play()
	endEngine.stop()
	await get_tree().create_timer(1).timeout
	mountedCharacter = character
	ui.visible = true
func unmount():
	if mountedCharacter != null:
		ui.visible = false
		var prevChar = mountedCharacter
		mountedCharacter = null
		startEngine.stop()
		endEngine.play()
		await get_tree().create_timer(1).timeout
		prevChar.forcedMove = false

func _ready():
	ui.visible = false
	for b in bodyExceptions:
		add_collision_exception_with(b)
func _process(delta):
	if mountedCharacter != null:
		# Unmount
		if Input.is_action_just_pressed("action_cancel"):
			unmount()
			return
		# Move forklift
		var rotate = move_toward(lastRotate,getHorz(),delta)
		var forward = move_toward(lastForward,getVert(),delta)
		lastRotate = rotate
		lastForward = forward
		startEngine.pitch_scale = remap(abs(forward),0,1,1,1.5)
		if forward > 0: rotate *= -1
		global_rotation_degrees.y -= rotate * delta * rotateSpeed
		velocity = forward * -moveSpeed * global_basis.z
		move_and_slide()
		mountedCharacter.global_position = attachPoint.global_position
		mountedCharacter.global_rotation = attachPoint.global_rotation

func getHorz():
	if !canMove(): return 0
	return Input.get_axis("move_left", "move_right")

func getVert():
	if !canMove(): return 0
	var f = Input.get_axis("move_up", "move_down")
	if f > 0: f/=2
	return f

func canMove():
	if Global.Ev.isBusy(): return false
	if Global.UI.busy(): return false
	return true

func getInteractOffset():
	return interactOffset
