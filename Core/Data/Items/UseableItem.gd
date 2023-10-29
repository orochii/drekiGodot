extends BaseItem
class_name UseableItem

@export_category("Target")
@export var targetKind : Global.ETargetKind
@export var targetScope : Global.ETargetScope
@export var targetState : Global.ETargetState

@export_category("Cost")
@export_range(0, 1) var spendOnUseChance : float
@export var canUse : Global.EUsePermit

@export_category("Effect")
@export var startSequence : Array[BaseEffect]
@export var actionSequence : Array[BaseEffect]
@export var endSequence : Array[BaseEffect]
