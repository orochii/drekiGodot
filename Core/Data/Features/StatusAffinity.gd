extends BaseFeature
class_name StatusAffinityFeature

const RANK_EFFECT = [1.0, 0.8, 0.6, 0.4, 0.2, 0.0]

@export var status : Status
@export var value : Global.Rank = Global.Rank.C

func getEffect():
	return RANK_EFFECT[value]
