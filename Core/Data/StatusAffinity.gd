extends Resource
class_name StatusAffinity

const RANK_EFFECT = [100, 80, 60, 40, 20, 0]

@export var status : Status
@export var value : Global.Rank = Global.Rank.C
