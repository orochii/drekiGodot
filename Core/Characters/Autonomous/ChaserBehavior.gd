extends NavigationAgent3D

@export var character:Character
@export_category("Behavior")
@export var range:float = 3
@export var viewAngle:float = 45
@export var retentionCooldown:float = 3.0
@export var reactionTimeFound:float = 1.0
@export var reactionTimeLost:float = 2.0

var retentionTimer:float = 0
var reactionTimer:float = 0
var reactionKind:StringName = &""
var chasing:bool = false
var enabled:bool = true

func setEnabled(v:bool):
	enabled = v
	if !enabled:
		character.stopNavigate()

func _process(delta):
	# Return if not enabled
	if !enabled: return
	#
	if character is NPC:
		var npc = character as NPC
		if npc.isEventRunning(): return
	
	var seen = _canSee(Global.Player)
	if seen:
		retentionTimer = retentionCooldown
		if !chasing:
			reactionTimer = reactionTimeFound
			reactionKind = &"exclamation"
			chasing = true
	else:
		if retentionTimer > 0:
			retentionTimer -= delta
			chasing = true
		else:
			if chasing:
				reactionTimer = reactionTimeLost
				reactionKind = &"question"
				chasing = false
	
	# React to seeing the player
	if reactionTimer > 0:
		if reactionKind != &"":
			character.showBalloon(reactionKind)
			reactionKind = &""
		reactionTimer -= delta
		if chasing:
			#stop
			character.stopNavigate()
			#look towards
			character.lookTowards(Global.Player.global_position)
		return
	
	# Execute movement
	if chasing:
		# Go towards player
		character.navigateTowards(Global.Player.global_position)
	else:
		# Move around
		var _rndDir = Vector3.FORWARD.rotated(Vector3.UP, randf()*PI)
		character.navigateTowards(character.global_position + _rndDir)
		reactionTimer = 1.0

func _canSee(p:Node3D):
	if p != null:
		var distSq = character.global_position.distance_squared_to(p.global_position)
		if (distSq < range*range):
			# check direction angle
			var rot = character.global_rotation
			var dir = p.global_position - character.global_position
			var dirRot = dir.rotated(Vector3.RIGHT, -rot.x).rotated(Vector3.UP, -rot.y).rotated(Vector3.FORWARD, -rot.z)
			var angle = dir.angle_to(Vector3.BACK)
			if angle < viewAngle:
				return true
	return false
