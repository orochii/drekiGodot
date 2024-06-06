extends Resource
class_name BaseItem

@export_group("Display")
@export var icon : Texture2D
@export var category : Global.EItemCategory

@export_group("Bartering")
@export var price : int
@export var canSell : bool = true

func getId():
	# res://Data/Items/Tonic.tres
	var len = resource_path.length()
	var dirlen = "res://Data/Items/".length()
	var extlen = ".tres".length()
	return resource_path.substr(dirlen, len-dirlen-extlen)

func isUseable(inBattle:bool):
	return false

func getName():
	return getId()
func getDesc():
	return getId() + "_desc"
