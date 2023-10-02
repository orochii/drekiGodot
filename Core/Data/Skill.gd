extends Resource
class_name Skill

enum ETargetKind { NONE, ALLY, ENEMY, ANY, USER }
enum ETargetScope { ONE, ALL, RANDOM }
enum ETargetState { ALIVE, DEAD, ANY }
enum EUsePermit { BATTLE, MAP, ANYWHERE }
enum ECostType { AmountMP, PercentMP }

@export_category("Display")
@export var name : String
@export var description : String
@export var icon : Texture2D

@export_category("Target")
@export var targetKind : ETargetKind
@export var targetScope : ETargetScope
@export var repeats : ETargetState

@export_category("Cost")
@export var cost : int
@export var mpCostPercent : ECostType
@export var canUse : EUsePermit

@export_category("Effect")
# idk if list of effects or what
