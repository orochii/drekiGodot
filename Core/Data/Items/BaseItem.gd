extends Resource
class_name BaseItem

@export_group("Display")
@export var name : String
@export var description : String
@export var icon : Texture2D
@export var category : Global.EItemCategory

@export_group("Bartering")
@export var price : int
@export var canSell : bool
