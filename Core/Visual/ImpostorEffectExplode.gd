extends Node3D

@export var testRun:bool
@export var particles:GPUParticles3D
var run:bool = false
var timer:float = 0

func _ready():
	if testRun:
		particles.emitting = true

func setup(target:Sprite3D):
	var offset = Vector3(target.offset.x, target.offset.y, 0) * target.pixel_size
	global_position = target.global_position + offset
	self.scale = target.scale
	var deg = target.global_rotation_degrees
	var origY = deg.y
	var camY = get_viewport().get_camera_3d().global_rotation_degrees.y
	if origY-camY > 0:
		camY -= 180
	deg.y = camY
	global_rotation_degrees = deg
	#
	var p = particles.process_material
	var extents = Vector3(target.texture.get_width(), target.texture.get_height(), 0)
	extents = extents * target.pixel_size / 2
	p.set_shader_parameter("emission_box_extents", extents)
	p.set_shader_parameter("sprite", target.texture)
	#await get_tree().
	particles.one_shot = true
	particles.emitting = true
	run = true

func _process(delta):
	if !run: return
	if particles.emitting: return
	
	if timer < (particles.lifetime + 0.5):
		timer += delta
		return
	
	queue_free()
