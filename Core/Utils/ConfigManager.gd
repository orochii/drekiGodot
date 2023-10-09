extends Object
class_name ConfigManager

var data = {}

func _init():
	loadConfig()
	# data["bindings"] = Global.Inputs.serializeBindings()

func loadConfig():
	if exist():
		var savegame = FileAccess.open(configFilename(),FileAccess.READ)
		var json = savegame.get_pascal_string()
		savegame.close()
		data = JSON.parse_string(json)
	else:
		data = {
			# Game settings: ActiveBattle, BattleSpeed, BattleCamera, SkilTutorials, PauseOnFocusLoss, Language
			"game":{
				"ActiveBattle":0, 
				"BattleSpeed":5, 
				"BattleCamera":1, 
				"SkilTutorials":0, 
				"PauseOnFocusLoss":1, 
				"Language":"en"
			},
			# Input bindings
			"bindings":{},
			# Graphics: ScreenScale, ScreenMode, MessageSkin, BackOpacity, BattleShadows, GamepadButtons
			"graphics":{
				"ScreenScale" : 2, 
				"ScreenMode" : 0, 
				"MessageSkin" : 0, 
				"BackOpacity" : 7, 
				"BattleShadows" : 2, 
				"GamepadButtons" : 0
			},
			# Audio: volume(master,bgm,bgs,amb,sfx)
			"audio":{
				"MasterVolume" : 100,
				"BGMVolume" : 100,
				"BGSVolume" : 100,
				"AmbVolume" : 100,
				"SFXVolume" : 100
			}
		}

func saveConfig():
	var savegame = FileAccess.open(configFilename(),FileAccess.WRITE)
	var json = JSON.stringify(data)
	savegame.store_pascal_string(json)
	savegame.close()

func exist():
	return DirAccess.dir_exists_absolute(configFilename())
func configPath() -> String:
	return "user://"
func configFilename() -> String:
	return configPath() + "config.dat"
