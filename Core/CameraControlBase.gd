extends Node3D
class_name CameraControlBase

@export var target : Node3D
@export var camera : Camera3D
@export var shaderQuad : MeshInstance3D
@export var interior : bool = false

var origTarget : Node3D
var lastTarget : Node3D

func _ready():
    shaderQuad.visible = !interior
    origTarget = target
    lastTarget = target
    Global.Camera = self

func saveRotation():
    return false

func getLayers():
    return camera.cull_mask

func setLayers(l:int):
    camera.cull_mask = l

func make_current():
    camera.make_current()