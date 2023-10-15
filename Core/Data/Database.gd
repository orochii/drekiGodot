extends Resource
class_name Database

@export_category("System")
@export var startingParty : Array[Actor]
@export var startingScene : PackedScene
@export var equipSlots : Array[SlotData]
@export var iconLibrary : IconLibrary

func getActor(id : StringName):
	return load("res://Data/Actors/%s.tres" % id)

func getEnemy(id : StringName):
	return load("res://Data/Enemies/%s.tres" % id)

func getItem(id : StringName):
	return load("res://Data/Items/%s.tres" % id)

func getSkill(id : StringName):
	return load("res://Data/Skills/%s.tres" % id)

func getSpritesheet(id : StringName):
	return load("res://Data/Spritesheets/%s.tres" % id)

func getStatus(id : StringName):
	return load("res://Data/Status/%s.tres" % id)

func getTroop(id : StringName):
	return load("res://Data/Troops/%s.tres" % id)
