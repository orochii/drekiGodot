extends Control
class_name FileMenu

@export var helpText : Label
@export var screenshotBack : NinePatchRect
@export var savefileTemplate : PackedScene
@export var saveslotTemplate : PackedScene
@export var fileContainer : Container
@export var slotContainer : Container
@export var savefileInfo : Control

var files:Array = []
var slots:Array = []

# 0: save 1:load
var currFolder = ""
var fileMode = 0
var fromMenu = false
var inputDelay = 0
var lastFocusedEntry = null

func _ready():
	visible = false

func _process(delta):
	if !visible: return
	if Global.UI.Config.visible: return
	
	# Update info
	var focused = get_viewport().gui_get_focus_owner()
	if slots.has(focused):
		if lastFocusedEntry != focused:
			lastFocusedEntry = focused
			savefileInfo.setup(focused.filename,focused.index)
			screenshotBack.texture = savefileInfo.screenshot
		# Back
		if Input.is_action_just_pressed("action_cancel"):
			Global.Audio.playSFX("cancel")
			for f in files:
				if f.folder == currFolder:
					f.grab_focus()
					currFolder = ""
					
	else:
		if lastFocusedEntry != focused:
			lastFocusedEntry = null
			#savefileInfo.setup("",0)
			#screenshotBack.texture = null
		# Back
		if Input.is_action_just_pressed("action_cancel"):
			Global.Audio.playSFX("cancel")
			close()
	# Delete
	if Input.is_action_just_pressed("action_extra"):
		pass

var lastFocus = null
func open(mode,fromMenu):
	lastFocus = get_viewport().gui_get_focus_owner()
	get_viewport().gui_release_focus()
	# Clear
	for f in slots:
		f.queue_free()
	slots.clear()
	savefileInfo.setup("",0)
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

func createSaveList():
	# Clear
	for f in files:
		f.queue_free()
	files.clear()
	
	# Make files
	var _files = Global.getSaveFileList()
	for i in _files:
		var inst = savefileTemplate.instantiate()
		inst.parent = self
		inst.setup(i)
		fileContainer.add_child(inst)
		files.append(inst)
	if fileMode==0:
		var inst = savefileTemplate.instantiate()
		inst.parent = self
		inst.setup("")
		fileContainer.add_child(inst)
		files.append(inst)
	UIUtils.setVNeighbors(files)
	if files.size() != 0:
		files[0].grab_focus()

func createSlotList():
	# Clear
	for f in slots:
		f.queue_free()
	slots.clear()
	# Make slots
	for i in range(24):
		var f:String = currFolder + "/save%03d" % i
		var inst = saveslotTemplate.instantiate()
		inst.parent = self
		inst.setup(f,i)
		slotContainer.add_child(inst)
		slots.append(inst)
	slots[0].grab_focus()

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

func onFileSelected(filename:String):
	if filename.is_empty():
		if fileMode==0:
			# Create new folder
			var newName = "default"
			Global.makeSaveFile(newName)
			currFolder = newName
			createSlotList()
	else:
		# Select folder
		currFolder = filename
		createSlotList()
func onSlotSelected(filename:String,exists:bool):
	if fileMode==0:
		Global.Audio.playSFX("save")
		Global.saveGame(filename)
	else:
		if !exists:
			Global.Audio.playSFX("buzzer")
			return
		Global.Audio.playSFX("load")
		Global.loadGame(filename)
		fromMenu = false
	lastFocus = null
	close()
