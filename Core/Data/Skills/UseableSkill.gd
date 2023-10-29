extends BaseSkill
class_name UseableSkill

enum ESkillFlags { PHYSICAL, MAGICAL, RANGED, CAN_REFLECT, CAN_GUARD }
enum ECostType { AmountMP, PercentMP }

@export var flags : Array[ESkillFlags]

@export_category("Target")
@export var targetKind : Global.ETargetKind
@export var targetScope : Global.ETargetScope
@export var targetState : Global.ETargetState
@export var repeats : int

@export_category("Cost")
@export var costType : ECostType
@export var cost : int
@export var charges : int
@export var cooldown : int
@export var canUse : Global.EUsePermit

@export_category("Effect")
@export var startSequence : Array[BaseEffect]
@export var actionSequence : Array[BaseEffect]
@export var endSequence : Array[BaseEffect]
