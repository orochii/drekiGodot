extends Node3D
class_name BattleManager

@export var testTroop:EnemyTroop
@export var camera:Camera3D
@export var battlerTemplate:PackedScene
@export var party:Node
@export var troop:Node
@export var partyPositionBase:Vector3 = Vector3(6,0,0)
@export var partyPositionOffset:Vector3 = Vector3(0,0,1)

func _ready():
	if (Global.State.party == null): Global.newGame()
	# Create scenario
	# Get current troop from state
	if (Global.State.currentTroop == null): Global.State.currentTroop = testTroop
	# Create battlers
	_createTroop()
	_createParty()
	pass # Replace with function body.

func _createParty():
	var members : Array = Global.State.party.members
	var startingPosition = partyPositionBase - (partyPositionOffset * (members.size()-1) / 2)
	for i in range(members.size()):
		var m = members[i]
		var actor = Global.State.getActor(m)
		var inst:Battler = battlerTemplate.instantiate()
		party.add_child(inst)
		inst.setup(actor)
		inst.global_position = startingPosition + (partyPositionOffset * i)
		inst.global_rotation_degrees = Vector3(0, -90, 0)

func _createTroop():
	var _troopData:EnemyTroop = Global.State.currentTroop
	if(_troopData == null): return
	
	for entry in _troopData.entries:
		entry.position
		var enemy = GameEnemy.new(entry.enemy.getId())
		var inst:Battler = battlerTemplate.instantiate()
		party.add_child(inst)
		inst.setup(enemy)
		inst.global_position = entry.position
		inst.global_rotation_degrees = Vector3(0, 90, 0)

func _process(delta):
	if(Input.is_action_just_pressed("action_cancel")):
		print("END?")
		Global.Scene.endBattle()
