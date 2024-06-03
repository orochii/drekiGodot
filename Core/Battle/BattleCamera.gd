extends SubViewport
class_name BattleCamera

const CAM_START_DUR:float = 2.5
const RAY_LENGTH:float = 1000.0

@export_group("Components")
@export var pivot:Node3D
@export var camera:Camera3D
@export var replicator:Camera3D
@export var viewportReplicator:SubViewport
@export var target:Node3D
@export var start:Node3D
@export_group("Speed")
@export var moveSpeed:float
@export var rotateSpeed:float
@export var zoomSpeed:float

var originalPosition:Vector3
var originalRotation:Vector3
var originalFov:float
var originalZoom:float
var targetZoom:float

func _enter_tree():
	if Global.Config != null: 
		Global.Config.onScreenSizeChange.connect(_updateScreenSize)
func _exit_tree():
	if Global.Config != null: 
		Global.Config.onScreenSizeChange.disconnect(_updateScreenSize)

func _zoomToFov(z):
	return originalFov * z

func _initOriginalValues():
	var window = get_window()
	_updateScreenSize(window.content_scale_size)
	camera.cull_mask = Global.Camera.getLayers()
	originalPosition = pivot.position
	originalRotation = pivot.rotation
	originalZoom = 1

func _updateScreenSize(newSize:Vector2i):
	size = newSize
	viewportReplicator.size = size
	var _oldSize = camera.size
	camera.size = newSize.y * Global.PIXEL_SIZE
	camera.fov = camera.fov * (newSize.y / _oldSize)
	replicator.size = camera.size
	replicator.fov = camera.fov
	originalFov = newSize.y * Global.PIXEL_FOV

func _ready():
	_initOriginalValues()
	goTo(start.global_position,start.global_rotation,1,true)
	reset(CAM_START_DUR)

func _process(delta):
	# lerp zoom
	pivot.position = pivot.position.move_toward(target.position, delta * moveSpeed)
	pivot.rotation = pivot.rotation.move_toward(target.rotation, delta * rotateSpeed)
	camera.fov = move_toward(camera.fov, _zoomToFov(targetZoom), delta * zoomSpeed)
	# replicate
	replicator.global_position = camera.global_position
	replicator.global_rotation = camera.global_rotation
	replicator.fov = camera.fov

func _calcSpeed(from:Vector3,to:Vector3,duration:float):
	if duration <= 0: return 0
	var dst = from.distance_to(to)
	return dst / duration

func moveTo(pos:Vector3,duration:float,global=false):
	if global:
		moveSpeed = _calcSpeed(target.global_position, pos, duration)
		target.global_position = pos
	else:
		moveSpeed = _calcSpeed(target.position, pos, duration)
		target.position = pos
	if duration <= 0: pivot.position = target.position
func rotateTo(rot:Vector3,duration:float,global=false):
	if global:
		rotateSpeed = _calcSpeed(target.global_rotation, rot, duration)
		target.global_rotation = rot
	else:
		rotateSpeed = _calcSpeed(target.rotation, rot, duration)
		target.rotation = rot
	if duration <= 0: pivot.rotation = target.rotation
func lookTo(pos:Vector3,duration:float):
	target.look_at(pos,target.get_parent_node_3d().basis.y)
	rotateTo(target.rotation,duration)
func zoomTo(zoom:float,duration:float):
	if duration <= 0: 
		camera.fov = _zoomToFov(targetZoom)
		zoomSpeed = 0
	else: 
		var dst = abs(_zoomToFov(zoom) - camera.fov)
		zoomSpeed = dst / duration
	targetZoom = zoom
func reset(duration):
	moveTo(originalPosition, duration)
	rotateTo(originalRotation, duration)
	zoomTo(originalZoom, duration)
func goTo(pos,rot,zoom,global=false):
	moveTo(pos,0,global)
	rotateTo(rot,0,global)
	zoomTo(zoom,0)

func posToScreen(pos : Vector3) -> Vector2:
	return camera.unproject_position(pos)

func posToWorld(pos : Vector2):
	var space_state = get_world_3d().direct_space_state
	var origin = camera.project_ray_origin(pos)
	var end = origin + camera.project_ray_normal(pos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end, 1)
	var result:Dictionary = space_state.intersect_ray(query)
	if result.is_empty():
		return end
	else:
		return result.position
