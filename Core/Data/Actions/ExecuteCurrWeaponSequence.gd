extends BaseEffect
class_name ExecuteCurrWeaponSequence

func execute(action:BattleAction):
	var b = action.battler.battler
	var skill:UseableSkill = b.getDefaultSkill(0)
	if b is GameActor:
		var a = b as GameActor
		var idx = a.getCurrWeaponIdx()
		skill = b.getDefaultSkill(idx)
		var equip:EquipItem = a.getEquip(idx)
		if equip != null:
			skill = equip.skill
	if skill != null:
		for eff in skill.actionSequence:
			await eff.execute(action)
