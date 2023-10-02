extends Resource
class_name Actor

enum Gender { MALE, FEMALE, NONE }
const MAX_LEVEL : int = 255

@export_category("Display")
@export var name : String
@export var description : String
@export var gender : Gender
@export var faceGraphic : Texture2D
@export var mapSprite : SpritesheetCollection
#@export var battleSprite : 

@export_category("Stats")
@export var startLevel : float
@export var mhp : Vector2i
@export var mmp : Vector2i
@export var str : Vector2i
@export var vit : Vector2i
@export var mag : Vector2i
@export var agi : Vector2i

@export_category("Equipment")
# starting equipment
# equippable categories (?)

@export_category("Learnings")
# skill tree data, including starting stuff
# (skillId, apReq, requirements)

@export_category("Element/States")
# element weakness
# status weakness
