extends Control
class_name FileMenu

@export var helpText : Label
@export var screenshotBack : NinePatchRect
@export var savefileTemplate : PackedScene
@export var container : Container
var fileInstances:Array=[]

# 0: save 1:load
var index = 0
var currPos:float = 0
var fileMode = 0
var fromMenu = false
var containerBasePosition:Vector2
var inputDelay = 0

func _ready():
	visible = false
	containerBasePosition = container.position

func _process(delta):
	if !visible: return
	currPos = move_toward(currPos,index,delta*10)
	refreshPosition()
	# a
	screenshotBack.texture = fileInstances[index].screenshot
	# Vertical
	if inputDelay > 0:
		inputDelay -= delta
		return
	var v = Input.get_axis("ui_down","ui_up")
	index = index - v
	if index != currPos:
		inputDelay = 0.25
	if index < 0:
		index = fileInstances.size()-1
		currPos = index
	elif index >= fileInstances.size():
		index = 0
		currPos = index
	# Select
	if Input.is_action_just_pressed("action_ok"):
		if fileMode==0:
			Global.Audio.playSFX("save")
			Global.saveGame("save%03d" % index)
		else:
			Global.Audio.playSFX("load")
			Global.loadGame("save%03d" % index)
			fromMenu = false
		lastFocus = null
		close()
	# Delete
	if Input.is_action_just_pressed("action_extra"):
		pass
	# Back
	if Input.is_action_just_pressed("action_cancel"):
		Global.Audio.playSFX("cancel")
		close()

func refreshPosition():
	container.position = containerBasePosition - Vector2(0, currPos * 64)

var lastFocus = null
func open(mode,fromMenu):
	lastFocus = get_viewport().gui_get_focus_owner()
	get_viewport().gui_release_focus()
	
	Global.Scene.askPause(self)
	Global.Scene.performTransition()
	if !fromMenu:
		await get_tree().create_timer(0.05).timeout
	Global.cacheScreenshot()
	fileMode = mode
	helpText.text = "save_help" if mode==0 else "load_help"
	self.fromMenu = fromMenu
	createSaveList()
	#
	visible = true
	currPos = index
	refreshPosition()

func createSaveList():
	# Clear
	for f in fileInstances:
		f.queue_free()
	fileInstances.clear()
	# Make
	var files = Global.getSaveList()
	for i in range(files.size()):
		var f:String = files[i]
		f = f.substr(0,f.length()-Global.saveExt().length())
		var inst = savefileTemplate.instantiate()
		inst.setup(f,i)
		container.add_child(inst)
		fileInstances.append(inst)
	if fileMode==0:
		var inst = savefileTemplate.instantiate()
		inst.setup("New file",files.size())
		container.add_child(inst)
		fileInstances.append(inst)

func close():
	if fromMenu:
		Global.Scene.performTransition()
		Global.UI.Party.open(6, [fileMode])
		visible = false
		Global.Scene.askUnpause(self)
	else:
		Global.freeScreenshot()
		Global.Scene.performTransition()
		await get_tree().create_timer(0.05).timeout
		visible = false
		await Global.Scene.onTransitionEnd
		Global.Scene.askUnpause(self)
		if(lastFocus != null): lastFocus.grab_focus()
