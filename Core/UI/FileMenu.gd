extends Control
class_name FileMenu

@export var helpText : Label
@export var screenshotBack : NinePatchRect
@export var savefileTemplate : PackedScene
@export var saveslotTemplate : PackedScene
@export var fileContainer : Container
@export var slotContainer : Container
@export var maxSlotsPerFile : int = 24
@export var savefileInfo : Control
@export var cursor:AnimatedSprite2D
@export var namingPopup:NamingPopup
@export var selectPopup:SelectPopup
@export var currFolderLabel:Label

var files:Array = []
var slots:Array = []

# 0: save 1:load
var currFolder = ""
var fileMode = 0
var fromMenu = false
var inputDelay = 0
var lastFocusedEntry = null

func _ready():
	cursor.play(&"default")
	visible = false

func _process(delta):
	if !visible: return
	if Global.UI.Config.visible: return
	currFolderLabel.text = currFolder
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
		if Input.is_action_just_pressed("action_extra"):
			var payload = {
				"message" : "Do you want to delete slot: %s?" % [focused.filename],
				"options" : ["Yes","No"]
			}
			toDelete = focused.filename
			selectPopup.onSubmit = onDeleteSlot
			selectPopup.pop(payload)
		positionCursor(focused)
	elif files.has(focused):
		if lastFocusedEntry != focused:
			lastFocusedEntry = null
			#savefileInfo.setup("",0)
			#screenshotBack.texture = null
		# Back
		if Input.is_action_just_pressed("action_cancel"):
			Global.Audio.playSFX("cancel")
			close()
		positionCursor(focused)
		# Delete file folder
		if Input.is_action_just_pressed("action_extra"):
			var payload = {
				"message" : "Do you want to delete file: %s?" % [focused.folder],
				"options" : ["Yes","No"]
			}
			toDelete = focused.folder
			selectPopup.onSubmit = onDeleteFolder
			selectPopup.pop(payload)

var toDelete = ""
func onDeleteFolder(payload):
	if payload["selection"] == 0:
		Global.deleteSaveFile(toDelete)
		currFolder = ""
		createSaveList()
func onDeleteSlot(payload):
	if payload["selection"] == 0:
		Global.deleteSaveFileSlot(toDelete)
		createSlotList()

var lastFocus = null
func open(mode,fromMenu):
	if Global.Config.lastSavefile != "":
		currFolder = Global.Config.lastSavefile.split("/")[0]
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
	files[0].grab_focus()
	if files.size() != 0:
		if !currFolder.is_empty():
			for f in files:
				if f.folder == currFolder:
					f.grab_focus()

func createSlotList():
	# Clear
	for f in slots:
		f.queue_free()
	slots.clear()
	# Make slots
	for i in range(maxSlotsPerFile):
		var f:String = currFolder + "/save%03d" % i
		var inst = saveslotTemplate.instantiate()
		inst.parent = self
		inst.setup(f,i)
		slotContainer.add_child(inst)
		slots.append(inst)
	UIUtils.setGridNeighbors(slots, 7)
	slots[0].grab_focus()
	if !Global.Config.lastSavefile.is_empty():
		for s in slots:
			if s.filename == Global.Config.lastSavefile:
				s.grab_focus()

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
			var payload = {"name":"default","max":11}
			namingPopup.pop(payload)
			namingPopup.onSubmit = onNameSubmit
	else:
		# Select folder
		currFolder = filename
		createSlotList()
func onSlotSelected(filename:String,exists:bool):
	if fileMode==0:
		Global.Audio.playSFX("save")
		Global.saveGame(filename)
		Global.Config.lastSavefile = filename
		Global.Config.saveConfig()
	else:
		if !exists:
			Global.Audio.playSFX("buzzer")
			return
		Global.Audio.playSFX("load")
		Global.loadGame(filename)
		fromMenu = false
	lastFocus = null
	close()

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(10,8)
	else:
		cursor.visible = false

func onNameSubmit(payload):
	print(payload)
	var newName = payload["name"]
	Global.makeSaveFile(newName)
	currFolder = newName
	createSaveList()
	createSlotList()
