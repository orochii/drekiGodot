extends Node

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
enum Stat { HP, MP, Str, Vit, Int, Agi, HitRate, Eva }
enum ETargetKind { NONE, ALLY, ENEMY, ANY, USER }
enum ETargetScope { ONE, ALL, RANDOM }
enum ETargetState { ALIVE, DEAD, ANY }
enum EUsePermit { BATTLE, MAP, ANYWHERE }

var UI : GameUI
var Ev : Interpreter
var Db : Database

func _init():
	Db = load("res://Data/database.tres")
	Ev = Interpreter.new()
