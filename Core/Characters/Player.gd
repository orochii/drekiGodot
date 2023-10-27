extends Character
class_name Player

var closeEvents : Array

func _ready():
	super._ready()

func _process(delta):
	var direction = Vector3.ZERO
	direction.x = getHorz()
	direction.z = getVert()
	var cam = get_viewport().get_camera_3d()
	if (cam != null):
		direction = direction.rotated(Vector3.UP, cam.global_rotation.y)
	setMove(direction)
	if getJump(): jump()
	if getInteract(): interact()
	
	if canMove() && Input.is_action_just_pressed("action_menu"):
		Global.Audio.playSFX("decision")
		Global.cacheScreenshot()
		Global.UI.Party.open()

func getHorz():
	if !canMove(): return 0
	return Input.get_axis("move_left", "move_right")

func getVert():
	if !canMove(): return 0
	return Input.get_axis("move_up", "move_down")

func getInteract():
	if !canMove(): return false
	return Input.is_action_just_pressed("action_ok")

func getJump():
	if !canMove(): return false
	return Input.is_action_just_pressed("action_extra")

func getDash():
	if !canMove(): return false
	return Input.is_action_pressed("action_run")

func canMove():
	if Global.Ev.isBusy(): return false
	if Global.UI.busy(): return false
	return true

func getSpeedMult():
	if getDash():
		return speedMult + .7
	return speedMult

func interact():
	var closestEv = null
	var closestDst = 1000000
	for ev in closeEvents:
		var dst = (ev.global_position - global_position).length_squared()
		if dst < closestDst:
			closestEv = ev
			closestDst = dst
	if closestEv != null: closestEv.onInteract()

func _on_area_3d_area_entered(area: Area3D):
	if area is Trigger:
		var trigger = area as Trigger
		trigger.onTouch()
		if !closeEvents.has(trigger): closeEvents.append(trigger)

func _on_area_3d_area_exited(area: Area3D):
	if area is Trigger:
		var trigger = area as Trigger
		if closeEvents.has(trigger): closeEvents.erase(trigger)

func _on_area_3d_body_entered(body: Node3D):
	if body is NPC:
		var npc = body as NPC
		npc.onTouch()
		if !closeEvents.has(npc): closeEvents.append(npc)

func _on_area_3d_body_exited(body: Node3D):
	if body is NPC:
		var npc = body as NPC
		if closeEvents.has(npc): closeEvents.erase(npc)
