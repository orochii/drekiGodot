extends Resource
class_name BaseSkill

@export_category("Display")
@export var icon : Texture2D

func getId():
	# res://Data/Items/Tonic.tres
	var len = resource_path.length()
	var dirlen = "res://Data/Skills/".length()
	var extlen = ".tres".length()
	return resource_path.substr(dirlen, len-dirlen-extlen)

func getName():
	return getId()
func getDesc():
	return getId() + "_desc"

func isUseable(inBattle:bool):
	return false
