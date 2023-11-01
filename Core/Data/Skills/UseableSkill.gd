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

func getMPCost(b:GameBattler):
	match costType:
		ECostType.AmountMP:
			return cost
		ECostType.PercentMP:
			return b.getMaxMP() * cost / 100
		_:
			return 0

func getMPCostString():
	match costType:
		ECostType.AmountMP:
			return "%d" % cost
		ECostType.PercentMP:
			return "%d%%" % cost
		_:
			return "?"

func isUseable(inBattle:bool):
	match canUse:
		Global.EUsePermit.ANYWHERE:
			return true
		Global.EUsePermit.BATTLE:
			return inBattle
		Global.EUsePermit.MAP:
			return !inBattle
