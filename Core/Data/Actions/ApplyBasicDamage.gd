extends BaseEffect
class_name ApplyBasicDamage

@export var base : int

func execute():
	print("Dealt %d damage!" % base)
