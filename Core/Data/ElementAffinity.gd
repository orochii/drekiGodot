extends Resource
class_name ElementAffinity

const RANK_EFFECT = [300, 200, 100, 50, 0, -100]

enum Element { 
	NONE, CUT, HIT, PIERCE, PROJECTILE, 
	FIRE, ICE, THUNDER, WATER, EARTH, WIND, LITE, GLOOM }
enum Rank { A, B, C, D, E, F }

@export var element : Element
@export var value : Rank = Rank.C
