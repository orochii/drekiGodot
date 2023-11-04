extends Control
class_name BattlePartyResultWindow

@export var partyEntryTemplate:PackedScene
@export var container:Container

func _ready():
	visible = false

func setup(data):
	for entry in data:
		# entry(actor,exp,ap)
		var inst = partyEntryTemplate.instantiate()
		inst.setup(entry["actor"], entry["exp"], entry["ap"])
		container.add_child(inst)
