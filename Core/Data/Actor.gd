extends Resource
class_name Actor

const MAX_LEVEL : int = 255

@export_category("Display")
@export var name : String
@export var description : String
@export var faceGraphic : Texture2D
@export var mapSprite : Spritesheet
@export var battleSprite : Spritesheet

@export_category("Flavor")
@export var gender : Global.Gender
@export var birthday : int
@export var birthmonth : Global.Month
@export var birthyear : int

@export_category("Stats")
@export var startLevel : float
@export var mhp : Vector2i
@export var mmp : Vector2i
@export var str : Vector2i
@export var vit : Vector2i
@export var mag : Vector2i
@export var agi : Vector2i

@export_category("Equipment")
@export var startingEquipment : Array[EquipItem]
@export var equippableFlags : Array[Global.EquipKind]

@export_category("Learnings")
@export var learnings : Array[SkillLearning]

@export_category("Element/States")
@export var elementAfinity : Array[ElementAffinity]
@export var statusAfinity : Array[StatusAffinity]
