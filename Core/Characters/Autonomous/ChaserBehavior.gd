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
var lastDistances:Array = []
var lastPosition:Vector3

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
		var _longTravel = false
		if lastDistances.size()==0:
			lastDistances.append(0)
		else:
			var _dst = lastPosition.distance_to(character.global_position)
			var _totalDst = _dst
			if lastDistances.size() > 5:
				for d in lastDistances:
					_totalDst += d
				if _totalDst > 5:
					_longTravel = true
					lastDistances.clear()
				else:
					lastDistances.append(_dst)
		# Move around
		var _rndDst = Vector3.FORWARD * randfn(1.5, 1.0)
		if _longTravel: Vector3.FORWARD * randfn(4.5, 1.0)
		var _rndDir = _rndDst.rotated(Vector3.UP, randf() * 2 * PI)
		character.navigateTowards(character.global_position + _rndDir)
		reactionTimer = 1.0
		lastPosition = character.global_position

func _canSee(p:Node3D):
	if p != null:
		var distSq = character.global_position.distance_squared_to(p.global_position)
		if (distSq < range*range):
			# check direction angle
			var dir = p.global_position - character.global_position
			var angle = dir.angle_to(character.global_basis.z)
			if angle < deg_to_rad(viewAngle):
				return true
	return false
