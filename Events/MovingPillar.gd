extends BaseEvent

@export var zone:CollisionShape3D
@export var switchId:int = 0
@export var camPosition:Node3D
@export var panningTime:float = 1.0
@export var panningWait:float = 2.0

var currentActivator:Node3D = null

func _run():
	# 
	var _result = false
	# Get object references
	var p = getPlayer()
	var o = self.get_parent()
	var _originalParent = o.get_parent()
	# Setup player
	p.state = &"push"
	p.fixedDirection = true
	p.customMove = true
	# Setup object
	var gpos = o.global_position
	var grot = o.global_rotation
	_originalParent.remove_child(o)
	p.add_child(o)
	o.global_position = gpos
	o.global_rotation = grot
	o.fixedDirection = true
	var offset = o.position
	var _min_ = 1.2
	if offset.length() < _min_:
		offset = offset.normalized() * _min_
		o.position = offset
	# Setup zone
	zone.disabled = false
	# Show UI for movement stuff
	
	while Input.is_action_pressed("action_ok"):
		o.speed = p.speed
		o.speedMult = p.speedMult
		# Need logic for movement
		var direction = Vector3.ZERO
		direction.x = Input.get_axis("move_left", "move_right")
		direction.z = Input.get_axis("move_up", "move_down")
		var cam = get_viewport().get_camera_3d()
		if (cam != null):
			direction = direction.rotated(Vector3.UP, cam.global_rotation.y)
		p.setMove(direction)
		if o.position.length() < _min_:
			o.position = offset
		if o.position.distance_squared_to(offset) > 0.1:
			break
		if currentActivator != null:
			_result = true
			break
		await get_tree().process_frame
	
	# Hide UI for movement stuff
	# Reset player
	p.state = &"base"
	p.fixedDirection = false
	p.customMove = false
	# Reset object
	gpos = o.global_position
	grot = o.global_rotation
	p.remove_child(o)
	_originalParent.add_child(o)
	o.global_position = gpos
	o.global_rotation = grot
	o.fixedDirection = false
	# Reset zone
	zone.disabled = true
	
	# Run result
	if _result:
		# Reposition over plate
		var newPos = currentActivator.global_position
		o.global_position = Vector3(newPos.x, o.global_position.y, newPos.z)
		# Move plate down
		currentActivator.global_position += Vector3(0,-1.25,0)
		# Show thing happening
		Global.Camera.panTowards(camPosition,panningTime)
		while Global.Camera.isPanning(): await get_tree().process_frame
		Global.State.setSwitch(switchId,true)
		await get_tree().create_timer(panningWait).timeout
		Global.Camera.resetTarget(panningTime)
		while Global.Camera.isPanning(): await get_tree().process_frame
