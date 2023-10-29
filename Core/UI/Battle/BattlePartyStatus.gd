extends Control
class_name BattlePartyStatus

@export var container:Container
@export var memberStatusTemplate:PackedScene

func setup(b:Battler):
	var inst:BattleMemberStatus = memberStatusTemplate.instantiate()
	inst.setup(b)
	container.add_child(inst)
