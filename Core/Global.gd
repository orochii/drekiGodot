extends Node

enum EquipKind {
	SWORD, GREAT_SWORD, KATANA, DAGGER, AXE, SPEAR, BOW, WHIP, HANDS, OTHER,
	SHIELD, GAUNTLET, LIGHT_ARMOR, MID_ARMOR, HEAVY_ARMOR, FEMALE, MAGICAL_ARMOR
}
enum Element { 
	NONE, CUT, HIT, PIERCE, PROJECTILE, 
	FIRE, ICE, THUNDER, WATER, EARTH, WIND, LITE, GLOOM
}
enum Rank { A, B, C, D, E, F }

var UI : GameUI
var Ev : Interpreter
var Db : Database

func _init():
	Db = load("res://Data/database.tres")
	Ev = Interpreter.new()
