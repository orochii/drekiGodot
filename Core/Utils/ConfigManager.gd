extends Object
class_name ConfigManager

var data = {}

func _init():
	loadConfig()

func loadConfig():
	if exist():
		var savegame = FileAccess.open(configFilename(),FileAccess.READ)
		var json = savegame.get_pascal_string()
		savegame.close()
		data = JSON.parse_string(json)
	else:
		data = {
			# Bindings
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
