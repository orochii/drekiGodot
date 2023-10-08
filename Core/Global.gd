extends Node3D

const COMPRESSION = FileAccess.COMPRESSION_GZIP

enum Gender { MALE, FEMALE, NONE }
enum Month { 
	JANUARY, FEBRUARY, MARCH, APRIL, MAY, JUNE,
	JULY, AUGUST, SEPTEMBER, OCTOBER, NOVEMBER, DECEMBER
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
enum Stat { HP, MP, Str, Vit, Mag, Agi, HitRate, Eva }
enum ETargetKind { NONE, ALLY, ENEMY, ANY, USER }
enum ETargetScope { ONE, ALL, RANDOM }
enum ETargetState { ALIVE, DEAD, ANY }
enum EUsePermit { BATTLE, MAP, ANYWHERE }

var UI : GameUI
var Ev : Interpreter
var Db : Database
var Audio : AudioManager
var State : GameState
var Scene : SceneManager
var scene = preload("res://Objects/scene_manager.tscn")

func _init():
	DirAccess.make_dir_absolute(savePath())
	Scene = scene.instantiate()
	add_child(Scene)
	Db = load("res://Data/database.tres")
	Ev = Interpreter.new()
	Audio = AudioManager.new()
	self.add_child(Audio)

func _ready():
	State = GameState.new()
	State.initialize()

func savePath() -> String:
	return "user://Slot/"
func saveExt() -> String:
	return ".sav"
func saveFilename(name:String) -> String:
	return savePath() + name + saveExt()

func getSaveList():
	return DirAccess.get_files_at(savePath())

func saveExist(name:String) -> bool:
	var dir = DirAccess.open(savePath())
	return dir.file_exists(saveFilename(name))

func saveGame(name:String):
	var savegame = FileAccess.open_compressed(saveFilename(name),FileAccess.WRITE, COMPRESSION)
	var savedata = State._serialize()
	var json = JSON.stringify(savedata)
	savegame.store_pascal_string(json)
	savegame.close()

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

func getSceneRoot():
	return UI.get_parent()
