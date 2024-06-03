extends EventPageCondition
class_name BattleHealthCondition

@export_category("Target")
@export_enum("Enemy","Party") var targetKind:int
@export var targetIdx:int
@export_category("Condition")
@export_enum("Percent","Specific") var conditionType:int
@export_enum("Below","Above") var conditionCompare:int
@export var conditionAmount:float

func check(ev) -> bool:
    var t:Battler = _getTarget()
    if t==null: return false
    var _c = t.battler.currHP
    if conditionType==0:
        _c = t.battler.currHP * 1.0 / t.battler.getMaxHP()
    match conditionCompare:
        0:
            return _c <= conditionAmount
        _:
            return _c > conditionAmount

func _getTarget():
    var ary = _getTargetAry()
    if targetIdx < ary.size():
        return ary[targetIdx]
    return null

func _getTargetAry():
    match targetKind:
        0:
            return Global.Battle.troopBattlers
        _:
            return Global.Battle.partyBattlers
