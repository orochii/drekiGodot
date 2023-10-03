extends Resource
class_name Database

@export_category("System")
@export var iconLibrary : IconLibrary

func getActor(id : StringName):
	return load("res://Data/Actors/%s.tres" % id)

func getSkill(id : StringName):
	return load("res://Data/Skills/%s.tres" % id)

func getItem(id : StringName):
	return load("res://Data/Items/%s.tres" % id)

func getSpritesheet(id : StringName):
	return load("res://Data/Spritesheets/%s.tres" % id)
