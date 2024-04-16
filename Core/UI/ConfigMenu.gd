extends Control
class_name ConfigMenu

@export var helpText:RichTextLabel
@export var scroll:ScrollContainer
@export var container:Container
@export var dropdownTemplate:PackedScene
@export var sliderTemplate:PackedScene
@export var bindingTemplate:PackedScene
@export var categoryButtons:Array[Button]
@export var cursor:AnimatedSprite2D

var allOptions:Array[BaseOption] = []
var currOptions:Array
var lastFocus = null
var fromMenu = false
var category:StringName = ""
var active:bool = true
var lastCategory = null

func _ready():
	visible = false
	cursor.play("default")
	generateOptions()
	applyFilter("game")
	UIUtils.setVNeighbors(categoryButtons)

func _process(delta):
	if !visible: return
	if !active: return
	
	var focused = get_viewport().gui_get_focus_owner()
	if(allOptions.has(focused)):
		positionCursor(focused)
		scroll.ensure_control_visible(focused)
		helpText.text = focused.getHelp()
		if !active: return
		# Back
		if Input.is_action_just_pressed("action_cancel"):
			Global.Audio.playSFX("cancel")
			lastCategory.grab_focus()
	elif(categoryButtons.has(focused)):
		positionCursor(focused)
		helpText.text = focused.name+"_help"
		if !active: return
		# Back
		if Input.is_action_just_pressed("action_cancel"):
			Global.Audio.playSFX("cancel")
			close()
	else:
		cursor.visible = false

func positionCursor(focused):
	if(focused != null):
		cursor.visible = true
		cursor.global_position = focused.global_position + Vector2(10,8)
	else:
		cursor.visible = false

func open(fromMenu):
	lastFocus = get_viewport().gui_get_focus_owner()
	get_viewport().gui_release_focus()
	
	Global.Scene.askPause(self)
	Global.Scene.performTransition()
	if !fromMenu:
		await get_tree().create_timer(0.05).timeout
	Global.cacheScreenshot()
	self.fromMenu = fromMenu
	applyFilter(category)
	visible = true
	categoryButtons[0].grab_focus()

func close():
	Global.Config.saveConfig()
	if fromMenu:
		Global.Scene.performTransition()
		Global.UI.Party.open(6, [2])
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

func applyFilter(newCat:StringName):
	category = newCat
	currOptions.clear()
	for entry in allOptions:
		entry.visible = entry.category == category
		if(entry.visible): 
			currOptions.append(entry)
			entry.onVisible()
	UIUtils.setVNeighbors(currOptions)

func generateOptions():
	# Game
	category = "game"
	var activeBattle:DropdownOption = createDropdown()
	activeBattle.setVariable(Global.Config, "activeBattle")
	activeBattle.setup("Active Battle")
	var battleSpeed:SliderOption = createSlider()
	battleSpeed.setVariable(Global.Config, "battleSpeed")
	battleSpeed.setup("Battle Speed", 1, 9)
	var battleCamera:DropdownOption = createDropdown()
	battleCamera.setVariable(Global.Config, "battleCamera")
	battleCamera.setup("Battle Camera")
	var skipTutorials:DropdownOption = createDropdown()
	skipTutorials.setVariable(Global.Config, "skipTutorials")
	skipTutorials.setup("Skip Tutorials")
	var pauseOnFocusLost:DropdownOption = createDropdown()
	pauseOnFocusLost.setVariable(Global.Config, "pauseOnFocusLost")
	pauseOnFocusLost.setup("Pause on Focus Lost")
	var language:DropdownOption = createDropdown()
	language.setVariable(Global.Config, "language")
	language.setup("Language", {"en":"English","es":"Spanish"})
	language.onValueChange = Global.Config.refreshLanguage
	# Audio
	category = "audio"
	var masterVolume:SliderOption = createSlider()
	masterVolume.setCallables(Global.Audio.getMasterVol, Global.Audio.setMasterVol)
	masterVolume.setup("Master Volume", 0, 10, 0.1)
	var bgmVolume:SliderOption = createSlider()
	bgmVolume.setCallables(Global.Audio.getBGMVol, Global.Audio.setBGMVol)
	bgmVolume.setup("BGM Volume", 0, 10, 0.1)
	var bgsVolume:SliderOption = createSlider()
	bgsVolume.setCallables(Global.Audio.getBGSVol, Global.Audio.setBGSVol)
	bgsVolume.setup("BGS Volume", 0, 10, 0.1)
	var ambVolume:SliderOption = createSlider()
	ambVolume.setCallables(Global.Audio.getAmbVol, Global.Audio.setAmbVol)
	ambVolume.setup("Ambient Volume", 0, 10, 0.1)
	var sfxVolume:SliderOption = createSlider()
	sfxVolume.setCallables(Global.Audio.getSFXVol, Global.Audio.setSFXVol)
	sfxVolume.setup("SFX Volume", 0, 10, 0.1)
	# Graphics
	category = "graphics"
	var screenResolution:DropdownOption = createDropdown()
	screenResolution.setVariable(Global.Config, "screenResolution")
	var resolutionOptions = {}
	for i in range(Global.Db.availableScreenResolutions.size()):
		var r:ScreenResolution = Global.Db.availableScreenResolutions[i]
		resolutionOptions[i] = r.displayName
	screenResolution.setup("Screen Resolution", resolutionOptions)
	screenResolution.onValueChange = Global.Config.refreshScreenSize
	var screenScale:SliderOption = createSlider()
	screenScale.setVariable(Global.Config, "screenScale")
	screenScale.setup("Screen Scale", 1, 4)
	screenScale.onValueChange = Global.Config.refreshScreenSize
	var screenMode:DropdownOption = createDropdown()
	screenMode.setVariable(Global.Config, "screenMode")
	screenMode.setup("Screen Mode", {true:"Fullscreen",false:"Windowed"})
	screenMode.onValueChange = Global.Config.refreshScreenSize
	var fpsLimit:DropdownOption = createDropdown()
	fpsLimit.setVariable(Global.Config, "fpsLimit")
	fpsLimit.setup("FPS Limit", {0:"Unlimited",15:"Fourth",20:"Third",30:"Half"})
	fpsLimit.onValueChange = Global.Config.refreshFps
	var messageSkin:DropdownOption = createDropdown()
	messageSkin.setVariable(Global.Config, "messageSkin")
	messageSkin.setup("Message Skin", {0:"White",1:"Dark"})
	var backOpacity:SliderOption = createSlider()
	backOpacity.setVariable(Global.Config, "backOpacity")
	backOpacity.setup("Background Opacity", 0, 10)
	var battleShadows:DropdownOption = createDropdown()
	battleShadows.setVariable(Global.Config, "battleShadows")
	battleShadows.setup("Shadow Style", {0:"Disabled",1:"Simple",2:"Animated"})
	var gamepadButtons:DropdownOption = createDropdown()
	gamepadButtons.setVariable(Global.Config, "gamepadButtons")
	gamepadButtons.setup("Gamepad Button Icons", {0:"8bitdo M30",1:"Xbox360",2:"PlayStation"})
	# Bindings
	category = "bindings"
	var allActions = InputMap.get_actions()
	for action in allActions:
		if action.begins_with("ui_") || action.begins_with("sys_"): continue
		var bind = createBinding()
		bind.setup(action, action)

func createDropdown() -> DropdownOption:
	var inst:DropdownOption = dropdownTemplate.instantiate()
	inst.category = category
	inst._parent = self
	container.add_child(inst)
	allOptions.append(inst)
	return inst

func createSlider() -> SliderOption:
	var inst:SliderOption = sliderTemplate.instantiate()
	inst.category = category
	inst._parent = self
	container.add_child(inst)
	allOptions.append(inst)
	return inst

func createBinding() -> BindingOption:
	var inst:BindingOption = bindingTemplate.instantiate()
	inst.category = category
	inst._parent = self
	container.add_child(inst)
	allOptions.append(inst)
	return inst

# Button actions
func _on_general_pressed():
	Global.Audio.playSFX("decision")
	lastCategory = get_viewport().gui_get_focus_owner()
	applyFilter("game")
	if currOptions.size() != 0: currOptions[0].grab_focus()

func _on_audio_pressed():
	Global.Audio.playSFX("decision")
	lastCategory = get_viewport().gui_get_focus_owner()
	applyFilter("audio")
	if currOptions.size() != 0: currOptions[0].grab_focus()

func _on_graphics_pressed():
	Global.Audio.playSFX("decision")
	lastCategory = get_viewport().gui_get_focus_owner()
	applyFilter("graphics")
	if currOptions.size() != 0: currOptions[0].grab_focus()

func _on_binding_pressed():
	Global.Audio.playSFX("decision")
	lastCategory = get_viewport().gui_get_focus_owner()
	applyFilter("bindings")
	if currOptions.size() != 0: currOptions[0].grab_focus()

func _on_back_pressed():
	Global.Audio.playSFX("decision")
	close()
