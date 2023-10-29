extends Control
class_name BattlerStatusManager

@export var statusTemplate:PackedScene

func setup(b:Battler,showCP:bool):
	var inst:BattlerStatusHUD = statusTemplate.instantiate()
	inst.setup(b,showCP)
	add_child(inst)
