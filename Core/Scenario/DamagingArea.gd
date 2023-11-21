extends Area3D

@export var respawnPosition:Vector3
@export var damageParticlesTemplate:PackedScene

var perc = 1.0
var currBody = null
var originalPos = null
var targetPos = null

func _ready():
	pass

func _process(delta):
	if (currBody != null):
		var newPos = lerp(originalPos,targetPos,perc)
		var heightPos = Vector3(0, sin(PI * perc), 0) * 7
		currBody.global_position = newPos + heightPos
		perc += delta*2
		if perc >= 1:
			currBody.forcedMove = false
			currBody = null

func _on_body_entered(body):
	if body is Player:
		respawn_player(body)

func respawn_player(body):
	perc = 0.0
	originalPos = body.global_position
	targetPos = body.lastGroundedPosition
	currBody = body
	currBody.forcedMove = true
	#
	var inst:VisualEffect = damageParticlesTemplate.instantiate()
	inst.setup(self, [body])
