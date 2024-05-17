extends Area3D

@export var respawnPosition:Vector3
@export var damageParticlesTemplate:PackedScene

var respawnings = []

func _process(delta):
	var toDelete = []
	for respawning in respawnings:
		respawning["targetPos"] = respawning["currBody"].getLastGroundedPosition()
		var newPos = lerp(respawning["originalPos"],respawning["targetPos"],respawning["perc"])
		var heightPos = Vector3(0, sin(PI * respawning["perc"]), 0) * 7
		respawning["currBody"].global_position = newPos + heightPos
		respawning["perc"] += delta*2
		if respawning["perc"] >= 1:
			respawning["currBody"].forcedMove = false
			toDelete.append(respawning)
	for d in toDelete:
		respawnings.erase(d)

func _on_body_entered(body):
	if body is Character:
		var c = body as Character
		if body.canRespawn: respawn_player(c)

func respawn_player(body):
	var respawning = {}
	respawning["perc"] = 0.0
	respawning["originalPos"] = body.global_position
	respawning["targetPos"] = body.getLastGroundedPosition()
	respawning["currBody"] = body
	respawning["currBody"].forcedMove = true
	respawnings.append(respawning)
	#
	var inst:VisualEffect = damageParticlesTemplate.instantiate()
	inst.setup(self, [body])
