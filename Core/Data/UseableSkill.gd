extends Resource
class_name UseableSkill

enum ESkillFlags { PHYSICAL, MAGICAL, RANGED, CAN_REFLECT, CAN_GUARD }
enum ETargetKind { NONE, ALLY, ENEMY, ANY, USER }
enum ETargetScope { ONE, ALL, RANDOM }
enum ETargetState { ALIVE, DEAD, ANY }
enum EUsePermit { BATTLE, MAP, ANYWHERE }
enum ECostType { AmountMP, PercentMP }

@export var flags : Array[ESkillFlags]

@export_category("Target")
@export var targetKind : ETargetKind
@export var targetScope : ETargetScope
@export var targetState : ETargetState
@export var repeats : int

@export_category("Cost")
@export var costType : ECostType
@export var cost : int
@export var charges : int
@export var cooldown : int
@export var canUse : EUsePermit

@export_category("Effect")
@export var actionSequence : Array[BaseEffect]
