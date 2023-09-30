extends Node3D

@export var target : Node3D
@export var camera : Camera3D

func _ready():
	position = target.position

func _process(delta):
	position = target.position
