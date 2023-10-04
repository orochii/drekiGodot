extends Resource
class_name StatEffect

enum Kind { AMOUNT, PERC }

@export var stat : Global.Stat
@export var kind : Kind
@export var amount : int = 0
