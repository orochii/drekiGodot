extends Node3D
class_name CharModel

@export var model:Node3D
@export var anims:Array[StringName] = [&"Standing",&"Run"]

var animation:AnimationPlayer
var blend:float = 0.8

func _ready():
	# I really don't like to do things through names but this will do for now.
	if model==null: model = self
	animation = model.get_node("AnimationPlayer")
	if animation != null: animation.play(anims[0])

func _process(delta):
	pass

func setPose(id:int,blend:float=-1):
	if animation != null: animation.play(anims[id],blend)
