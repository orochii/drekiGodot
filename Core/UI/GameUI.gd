extends Control
class_name GameUI

@export var Message : GameMessage
@export var Party : PartyMenu
@export var File : FileMenu
@export var Config : ConfigMenu
@export var compass:Node3D

var currLang = "en"
var perfLabel:Label = null
var debugVisible:bool = true

func _init():
	Global.UI = self
	perfLabel = Label.new()
	perfLabel.scale = Vector2.ONE*0.5
	add_child(perfLabel)

func _process(delta):
	Global.State.playTime += delta
	if compass != null:
		var cam = get_viewport().get_camera_3d()
		compass.global_rotation = cam.global_rotation
	perfLabel.visible = debugVisible
	if debugVisible:
		refreshPerformanceLabel()

func refreshPerformanceLabel():
	var monitors = {
		"fps" : Performance.get_monitor(Performance.TIME_FPS),
		"ProcTime" : Performance.get_monitor(Performance.TIME_PROCESS),
		"PhysTime" : Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS),
		"ObjCount" : Performance.get_monitor(Performance.OBJECT_COUNT),
		"RenderOb" : Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME),
		"RndrPrim" : Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"DrawCall" : Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"Memory" : Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	}
	var str = ""
	for key in monitors:
		str += "%s : %s \n" % [key,monitors[key]]
	perfLabel.text = str

func busy():
	if Global.Scene.transferring: return true
	if (Message.busy()): return true
	return false

func posToScreen(pos : Vector3) -> Vector2:
	var cam = get_viewport().get_camera_3d()
	return cam.unproject_position(pos)

func screenSize() -> Vector2:
	return get_viewport().get_visible_rect().size
