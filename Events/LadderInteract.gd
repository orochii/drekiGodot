extends BaseEvent

@export var activator:Trigger
@export var lowerPos:Node3D
@export var upperPos:Node3D
@export var lowerTarget:Node3D
@export var upperTarget:Node3D

func _run():
	if activator != null:
		if !activator.getLocalVar(&"dropped"): return
	Global.Player.state = &"climb"
	Global.Player.forcedMove = true
	Global.Player.graphic.state = Global.Player.state
	Global.Player.graphic.speed = 0
	
	var l = inverse_lerp(lowerPos.global_position.y, upperPos.global_position.y, Global.Player.global_position.y)
	
	var active = true
	while(active):
		var move = Input.get_axis("move_down","move_up")
		Global.Player.graphic.speed = abs(move)
		l = l + (move * get_process_delta_time())
		if abs(move) > 0.5:
			if l > 1.0 || l < 0.0:
				active = false
		l = clampf(l, 0.0, 1.0)
		Global.Player.global_position = lerp(lowerPos.global_position,upperPos.global_position,l)
		Global.Player.global_rotation = lerp(lowerPos.global_rotation,upperPos.global_rotation,l)
		await get_tree().process_frame
	
	var l_dst = lowerTarget.global_position.distance_squared_to(Global.Player.global_position)
	var u_dst = upperTarget.global_position.distance_squared_to(Global.Player.global_position)
	if l_dst > u_dst: #<>
		Global.Player.global_position = upperTarget.global_position
		Global.Player.global_rotation = upperTarget.global_rotation
	else:
		Global.Player.global_position = lowerTarget.global_position
		Global.Player.global_rotation = lowerTarget.global_rotation
	
	Global.Player.forcedMove = false
	Global.Player.state = &""
