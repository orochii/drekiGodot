extends Character
class_name Player

func _ready():
	pass

func _process(delta):
	var direction = Vector3.ZERO
	direction.x = getHorz()
	direction.z = getVert()
	var cam = get_viewport().get_camera_3d()
	if (cam != null):
		direction = direction.rotated(Vector3.UP, cam.global_rotation.y)
	setMove(direction)
	if getJump(): jump()

func getHorz():
	if !canMove(): return 0
	return Input.get_axis("move_left", "move_right")

func getVert():
	if !canMove(): return 0
	return Input.get_axis("move_up", "move_down")

func getJump():
	if !canMove(): return false
	return Input.is_action_just_pressed("action_extra")

func canMove():
	if Global.Ev.isBusy(): return false
	if Global.UI.Message.busy(): return false
	return true

func _on_area_3d_area_entered(area: Area3D):
	print("AREA enters: " + area.name)

func _on_area_3d_area_exited(area: Area3D):
	print("AREA exits: " + area.name)

func _on_area_3d_body_entered(body: Node3D):
	print("BODY enters: " + body.name)
	if body is NPC:
		var npc = body as NPC
		npc.onTouch()

func _on_area_3d_body_exited(body: Node3D):
	print("BODY exits: " + body.name)
