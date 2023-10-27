extends Object
class_name ConfigManager

const SCREEN_SIZE:Vector2i = Vector2i(480,270)

# Game
var activeBattle : bool = false
var battleSpeed : int = 5
var battleCamera : bool = true
var skipTutorials : bool = false
var pauseOnFocusLost : bool = true
var language : String = "en"
# Graphics
var screenScale : int = 2
var screenMode : bool = false
var messageSkin : int = 0
var backOpacity : int = 8
var battleShadows : int = 2
var gamepadButtons : int = 0

func _init():
	loadConfig()

func loadConfig():
	if exist():
		var savegame = FileAccess.open(configFilename(),FileAccess.READ)
		var json = savegame.get_pascal_string()
		savegame.close()
		var data = JSON.parse_string(json)
		deserialize(data)

func saveConfig():
	var data = serialize()
	var savegame = FileAccess.open(configFilename(),FileAccess.WRITE)
	var json = JSON.stringify(data)
	savegame.store_pascal_string(json)
	savegame.close()

func exist():
	var dir = DirAccess.open(configPath())
	return dir.file_exists(configFilename())
#return DirAccess.dir_exists_absolute(configFilename())
func configPath() -> String:
	return "user://"
func configFilename() -> String:
	return configPath() + "config.dat"

func serialize() -> Dictionary:
	var data = {
		# Game settings: ActiveBattle, BattleSpeed, BattleCamera, SkipTutorials, PauseOnFocusLoss, Language
		"game":{
			"ActiveBattle" : activeBattle, 
			"BattleSpeed" : battleSpeed, 
			"BattleCamera" : battleCamera, 
			"SkipTutorials" : skipTutorials, 
			"PauseOnFocusLost" : pauseOnFocusLost, 
			"Language" : language
		},
		# Input bindings
		"bindings":Global.Inputs.serializeBindings(),
		# Graphics: ScreenScale, ScreenMode, MessageSkin, BackOpacity, BattleShadows, GamepadButtons
		"graphics":{
			"ScreenScale" : screenScale, 
			"ScreenMode" : screenMode, 
			"MessageSkin" : messageSkin, 
			"BackOpacity" : backOpacity, 
			"BattleShadows" : battleShadows, 
			"GamepadButtons" : gamepadButtons
		},
		# Audio: volume(master,bgm,bgs,amb,sfx)
		"audio":{
			"MasterVolume" : Global.Audio.getMasterVol(),
			"BGMVolume" : Global.Audio.getBGMVol(),
			"BGSVolume" : Global.Audio.getBGSVol(),
			"AmbVolume" : Global.Audio.getAmbVol(),
			"SFXVolume" : Global.Audio.getSFXVol()
		}
	}
	return data

func deserialize(data : Dictionary):
	if data.has("game"):
		var game = data["game"]
		if(game.has("ActiveBattle")): activeBattle = game["ActiveBattle"]
		if(game.has("BattleSpeed")): battleSpeed = game["BattleSpeed"]
		if(game.has("BattleCamera")): battleCamera = game["BattleCamera"]
		if(game.has("SkipTutorials")): skipTutorials = game["SkipTutorials"]
		if(game.has("PauseOnFocusLost")): pauseOnFocusLost = game["PauseOnFocusLost"]
		if(game.has("Language")): language = game["Language"]
	if data.has("bindings"):
		Global.Inputs.deserializeBindings(data["bindings"])
	if data.has("graphics"):
		var graphics = data["graphics"]
		if(graphics.has("ScreenScale")): screenScale = graphics["ScreenScale"]
		if(graphics.has("ScreenMode")): screenMode = graphics["ScreenMode"]
		if(graphics.has("MessageSkin")): messageSkin = graphics["MessageSkin"]
		if(graphics.has("BackOpacity")): backOpacity = graphics["BackOpacity"]
		if(graphics.has("BattleShadows")): battleShadows = graphics["BattleShadows"]
		if(graphics.has("GamepadButtons")): gamepadButtons = graphics["GamepadButtons"]
	if data.has("audio"):
		var audio = data["audio"]
		if(audio.has("MasterVolume")): Global.Audio.setMasterVol(audio["MasterVolume"])
		if(audio.has("BGMVolume")): Global.Audio.setBGMVol(audio["BGMVolume"])
		if(audio.has("BGSVolume")): Global.Audio.setBGSVol(audio["BGSVolume"])
		if(audio.has("AmbVolume")): Global.Audio.setAmbVol(audio["AmbVolume"])
		if(audio.has("SFXVolume")): Global.Audio.setSFXVol(audio["SFXVolume"])
	refreshLanguage()
	refreshScreenSize()

func refreshLanguage():
	TranslationServer.set_locale(language)

func refreshScreenSize():
	var window = Global.get_window()
	if screenMode:
		window.mode = Window.MODE_FULLSCREEN
	else:
		window.mode = Window.MODE_WINDOWED
		window.size = SCREEN_SIZE * screenScale
		#window.content_scale_factor = screenScale
		centerWindow()

func centerWindow():
	var screenPosition = DisplayServer.screen_get_position()
	var screenSize = DisplayServer.screen_get_size()
	var windowSize = DisplayServer.window_get_size()
	DisplayServer.window_set_position(screenPosition + ((screenSize-windowSize) / 2))
