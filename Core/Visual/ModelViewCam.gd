extends Node3D

@export var camera:Camera3D
@export var rotationSpeed:float = 60.0
@export var zoomSpeed:float = 25.0
@export var zoomLimit:Vector2 = Vector2(2,8)
@export var fovLimit:Vector2 = Vector2(20,75)

var currentAngle:Vector3
var currentZoom:float = 0.5

func _ready():
	pass

func _process(delta):
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var zoom = Input.get_axis("cycle_left","cycle_right")
	#
	currentAngle.y = currentAngle.y + dir.x*delta*rotationSpeed
	currentAngle.x = clamp(currentAngle.x + dir.y*delta*rotationSpeed, -90, 90)
	rotation_degrees = currentAngle
	currentZoom = clampf(currentZoom + zoom*delta, 0, 1)
	camera.position.z = lerp(zoomLimit.x, zoomLimit.y, currentZoom)
	camera.fov = lerp(fovLimit.x, fovLimit.y, currentZoom)