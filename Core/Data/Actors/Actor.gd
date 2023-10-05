extends Resource
class_name Actor

const MAX_LEVEL : int = 255

@export_group("Display")
@export var name : String
@export var jobName : String
@export var description : String
@export var faceGraphic : Texture2D
@export var mapSprite : Spritesheet
@export var battleSprite : Spritesheet

@export_group("Flavor")
@export var gender : Global.Gender
@export var birthday : int
@export var birthmonth : Global.Month
@export var birthyear : int

@export_group("Equipment")
@export var startingEquipment : Array[EquipItem]
@export var equippableFlags : Array[Global.EquipKind]

@export_group("Learnings")
@export var learningSlots : Array[SkillLearningSlot]

@export_group("Features")
@export var features : Array[BaseFeature]

@export_group("Stats")
@export var startLevel : float
@export var mhp : Vector2i
@export var mmp : Vector2i
@export var str : Vector2i
@export var vit : Vector2i
@export var mag : Vector2i
@export var agi : Vector2i
