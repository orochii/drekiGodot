extends Node3D

const COMPRESSION = FileAccess.COMPRESSION_GZIP
# Camera stuff
const PIXEL_SIZE = 0.0625
const PIXEL_FOV = 0.07407407407407407407407407407407

enum Gender { MALE, FEMALE, NONE }
enum Month { 
	JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE,
	JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER
}
enum EItemCategory {
	MEDICINE, INGREDIENT, SCROLL, EQUIP, KEY, UNIQUE
}
enum EquipSlot {
	ARMS, HEAD, BODY, ACCESSORY
}
enum EquipKind {
	SWORD, GREAT_SWORD, KATANA, DAGGER, AXE, SPEAR, BOW, WHIP, HANDS, OTHER,
	SHIELD, GAUNTLET, LIGHT_ARMOR, MID_ARMOR, HEAVY_ARMOR, FEMALE, MAGICAL_ARMOR
}
enum Element { 
	NONE, CUT, HIT, PIERCE, PROJECTILE, 
	FIRE, ICE, THUNDER, WATER, EARTH, WIND, LITE, GLOOM,
	HEALING
}
enum Rank { A, B, C, D, E, F }
enum Stat { HP, MP, Str, Vit, Mag, Agi, HitRate, Eva, PhyAbs, MagAbs, Atk }
enum ETargetKind { NONE, ALLY, ENEMY, ANY, USER }
enum ETargetScope { ONE, ALL, RANDOM }
enum ETargetState { ALIVE, DEAD, ANY }
enum EUsePermit { BATTLE, MAP, ANYWHERE }
enum EDamageType { HP,MP}

# NoHands and NoMove try to mimic Live a Live's arm/leg restriction, 
# while NoMagic is for sealing off magic specifically
enum ERestriction { None, NoHands, NoMove, NoMagic, AttackAnyone, AttackEnemy, AttackAlly, CantMove }

enum EStatusFlags {
	NON_RESISTANCE = 1,
	INCAPACITATED = 2,
	NO_EXP = 4,
	NO_EVADE = 8
}
enum EStatusActivation {
	TURN,
	MILLISECONDS
}

var Camera : CameraControl
var UI : GameUI
var Ev : Interpreter
var Db : Database
var Player : Player = null
var Config : ConfigManager
var Audio : AudioManager
var State : GameState
var Scene : SceneManager
var Inputs : InputManager
var scene = preload("res://Objects/scene_manager.tscn")

func _init():
	DirAccess.make_dir_absolute(savePath())
	DirAccess.make_dir_absolute(snapPath())
	Scene = scene.instantiate()
	add_child(Scene)
	print("LOAD Database")
	Db = load("res://Data/database.tres")
	Ev = Interpreter.new()
	Audio = AudioManager.new()
	self.add_child(Audio)
	# TODO: Input interface
	Inputs = InputManager.new()
	add_child(Inputs)

func _ready():
	Config = ConfigManager.new()
	#newGame()
	State = GameState.new()

func newGame():
	State = GameState.new()
	State.initialize()

func savePath() -> String:
	return "user://Slot/"
func snapPath() -> String:
	return "user://Snap/"
func saveExt() -> String:
	return ".sav"
func saveFilename(name:String) -> String:
	return savePath() + name + saveExt()

func deleteSaveFile(name:String):
	var path = savePath() + "%s/" % name
	# Delete all files inside
	var files = DirAccess.get_files_at(path)
	for f in files:
		print(f)
		DirAccess.remove_absolute(path+f)
	# Now delete folder
	DirAccess.remove_absolute(path)
func deleteSaveFileSlot(name:String):
	var path = savePath() + name
	DirAccess.remove_absolute(path + saveExt())
	DirAccess.remove_absolute(path + ".png")

func makeSaveFile(name:String):
	DirAccess.make_dir_absolute(savePath() + "%s/"%name)
func getSaveFileList():
	return DirAccess.get_directories_at(savePath())

func getSaveSlotList():
	var allFiles = DirAccess.get_files_at(savePath())
	var filtered = []
	for f in allFiles:
		if f.ends_with(saveExt()): filtered.append(f)
	return filtered

func saveExist(name:String) -> bool:
	var dir = DirAccess.open(savePath())
	return dir.file_exists(saveFilename(name))

func saveGame(name:String):
	var savegame = FileAccess.open_compressed(saveFilename(name),FileAccess.WRITE, COMPRESSION)
	var savedata = State._serialize()
	var json = JSON.stringify(savedata)
	savegame.store_pascal_string(json)
	savegame.close()
	saveGameScreenshot(name)

func loadGame(name:String):
	if !saveExist(name): return
	var savegame = FileAccess.open_compressed(saveFilename(name),FileAccess.READ, COMPRESSION)
	var json = savegame.get_pascal_string()
	savegame.close()
	var savedata = JSON.parse_string(json)
	# Load state, load map, then on map load finished 
	# try to deserialize characters
	State._deserialize(savedata)
	Scene.transfer(State.lastSceneName)

func saveGameScreenshot(name:String):
	if(lastScreenshot==null): return
	var path = savePath() + name + ".png"
	lastScreenshot.save_png(path)

func loadGameScreenshot(name:String):
	var path = savePath() + name + ".png"
	var dir = DirAccess.open(savePath())
	if dir.file_exists(path):
		var img = Image.load_from_file(path)
		return ImageTexture.create_from_image(img)
	return null

func readGame(name:String) -> Dictionary:
	if !saveExist(name): return {}
	var savegame = FileAccess.open_compressed(saveFilename(name),FileAccess.READ, COMPRESSION)
	var json = savegame.get_pascal_string()
	savegame.close()
	var savedata = JSON.parse_string(json)
	return savedata

func getSceneRoot():
	if Scene.currentScene != null: return Scene.currentScene
	return UI.get_parent()

func saveScreenshot():
	var name = snapPath() + State.getScreenshotTimestamp() + ".png"
	var img = get_viewport().get_texture().get_image()
	img.save_png(name)
	#var tex = ImageTexture.create_from_image(img)

var lastScreenshot = null
func cacheScreenshot():
	if lastScreenshot == null:
		lastScreenshot = get_viewport().get_texture().get_image()
func freeScreenshot():
	lastScreenshot = null

#Dir inspect or something
func get_dir_contents(rootPath: String) -> Array:
	var files = []
	var directories = []
	var dir = DirAccess.open(rootPath)
	
	if dir != null:
		dir.include_hidden = false
		dir.include_navigational = false
		dir.list_dir_begin()
		_add_dir_contents(dir, files, directories)
	else:
		push_error("An error occurred when trying to access the path.")
	return [files, directories]

func _add_dir_contents(dir: DirAccess, files: Array, directories: Array):
	var file_name = dir.get_next()
	while (file_name != ""):
		var path = dir.get_current_dir() + "/" + file_name
		if dir.current_is_dir():
			var subDir = DirAccess.open(path)
			subDir.include_hidden = false
			subDir.include_navigational = false
			subDir.list_dir_begin()
			directories.append(path)
			_add_dir_contents(subDir, files, directories)
		else:
			files.append(path)
		file_name = dir.get_next()
	dir.list_dir_end()
