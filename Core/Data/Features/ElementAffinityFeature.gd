extends BaseFeature
class_name ElementAffinityFeature

const WEAPON_ELEMENTS = [Global.Element.CUT, Global.Element.HIT, Global.Element.PIERCE, Global.Element.PROJECTILE]
const RANK_EFFECT = [3.0, 2.0, 1.0, 0.5, 0.0, -1.0]
const WEAPON_RANK_EFFECT = [3.0, 2.0, 1.0, 0.7, 0.3, 0.1]

@export var element : Global.Element
@export var value : Global.Rank = Global.Rank.C

func getEffect():
	if WEAPON_ELEMENTS.has(element):
		return WEAPON_RANK_EFFECT[value]
	else:
		return RANK_EFFECT[value]
