extends Control
class_name GameUI

signal onHpChange(actor,max)
signal onMpChange(actor,max)
signal onStatusChange(actor)
signal onLimitChange()

@export var Message : GameMessage
@export var Party : PartyMenu
@export var File : FileMenu
@export var Config : ConfigMenu
@export var Debug : Control
@export var interactPopup : Control
@export var popupParent : Control
@export var subsceneParent : Control
@export var itemPopupTemplate : PackedScene

var currLang = "en"
var perfLabel:Label = null
var colorShader:ColorRect = null
var debugVisible:bool = false

func _init():
	Global.UI = self
	# Create perf label
	perfLabel = Label.new()
	add_child(perfLabel)
	perfLabel.scale = Vector2.ONE*0.5
	perfLabel.z_as_relative = false
	perfLabel.z_index = RenderingServer.CANVAS_ITEM_Z_MAX - 1

func _ready():
	# Create color shader
	colorShader = ColorRect.new()
	add_child(colorShader)
	colorShader.layout_mode = 1
	colorShader.set_anchors_preset(PRESET_FULL_RECT, true)
	colorShader.z_as_relative = true
	colorShader.z_index = 202	#RenderingServer.CANVAS_ITEM_Z_MAX
	#colorShader.color = Color.WHITE
	var m = ShaderMaterial.new()
	m.shader = load("res://Core/Shaders/sh16bppfilter.gdshader")
	colorShader.material = m
	colorShader.process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	Global.State.playTime += delta
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
	if (Debug.visible): return true
	return false

func getEnabledColor(v:bool):
	if v:
		return Color.WHITE
	else:
		return Color(1,1,1,0.25)

func posToScreen(pos : Vector3) -> Vector2:
	var cam = get_viewport().get_camera_3d()
	return cam.unproject_position(pos)

func screenSize() -> Vector2:
	return get_viewport().get_visible_rect().size

func createItemPopup(item:BaseItem,amount:int,pos:Vector3):
	var i = itemPopupTemplate.instantiate()
	popupParent.add_child(i)
	i.setup(item,amount,posToScreen(pos))

func updateInteractPopup(ev:Node3D):
	if ev==null:
		interactPopup.visible = false
	else:
		interactPopup.visible = true
		interactPopup.position = posToScreen(ev.global_position + Vector3(0, ev.getInteractOffset(), 0))
