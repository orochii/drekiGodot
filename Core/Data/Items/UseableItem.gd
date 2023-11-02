extends BaseItem
class_name UseableItem

@export_category("Target")
@export var targetKind : Global.ETargetKind
@export var targetScope : Global.ETargetScope
@export var targetState : Global.ETargetState

@export_category("Cost")
@export_range(0, 1) var spendOnUseChance : float
@export_range(0, 1) var cpCost : float = 0.6
@export var canUse : Global.EUsePermit

@export_category("Effect")
@export var startSequence : Array[BaseEffect]
@export var actionSequence : Array[BaseEffect]
@export var endSequence : Array[BaseEffect]

func isUseable(inBattle:bool):
	match canUse:
		Global.EUsePermit.ANYWHERE:
			return true
		Global.EUsePermit.BATTLE:
			return inBattle
		Global.EUsePermit.MAP:
			return !inBattle
