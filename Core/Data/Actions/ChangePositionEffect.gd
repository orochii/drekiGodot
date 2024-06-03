extends BaseEffect
class_name ChangePositionEffect

@export var targetPosition:int = 0

func execute(action:BattleAction):
    for t in action.targets:
        t.battler.setPosition(targetPosition)
