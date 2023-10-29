extends BaseFeature
class_name ElementAffinityFeature

const RANK_EFFECT = [3.0, 2.0, 1.0, 0.5, 0.0, -1.0]

@export var element : Global.Element
@export var value : Global.Rank = Global.Rank.C

func getEffect():
	return RANK_EFFECT[value]
