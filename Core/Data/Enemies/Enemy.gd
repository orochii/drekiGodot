extends Resource
class_name Enemy

@export_group("Display")
@export var name : String
@export var type : String
@export var description : String
@export var battleSprite : Spritesheet

@export_group("Flavor")
@export var gender : Global.Gender = Global.Gender.NONE

@export_group("Features")
@export var features : Array[BaseFeature]

@export_group("Stats")
@export var level : int
@export var mhp : int
@export var mmp : int
@export var str : int
@export var vit : int
@export var mag : int
@export var agi : int

@export_group("Actions")
@export var actions : Array[EnemyScript]

@export_group("Rewards")
@export var rewardExp : int
@export var rewardGold : int
@export var rewardItems : Array[BaseItem]
