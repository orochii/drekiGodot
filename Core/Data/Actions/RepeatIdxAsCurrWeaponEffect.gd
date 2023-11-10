extends BaseEffect
class_name RepeatIdxAsCurrWeaponEffect

func execute(action:BattleAction):
	action.battler.setWeaponIndex(action.repeatIdx)
