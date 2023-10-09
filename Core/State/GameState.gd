extends Object
class_name GameState

const MAX_SWITCHES = 50
const MAX_VARIABLES= 50

signal onSwitchChange(id:int,value:bool)
signal onVariableChange(id:int,value:int)

# actor states
var actors : Array[GameActor] = []
# party stuff: members, inventory
var party : GameParty
# switches/variables
var switches : Array = []
var variables : Array = []
# map state
var _characters = null
var lastSceneName : String = ""

func initialize():
	party = GameParty.new()
	switches.resize(MAX_SWITCHES)
	variables.resize(MAX_VARIABLES)

func getSwitch(id:int) -> bool:
	if (id >= switches.size() || id < 0): return false
	return switches[id]==true
func setSwitch(id:int,v:bool):
	if (id < 0): return
	if id >= switches.size():
		switches.resize(id + 100)
	var prevVal = switches[id]==true
	switches[id] = v
	if prevVal != v:
		onSwitchChange.emit(id,v)

func getVariable(id:int) -> int:
	if (id >= variables.size() || id < 0): return false
	if variables[id]==null: return 0
	else: return variables[id]
func setVariable(id:int,v:int):
	if (id < 0): return
	if id >= variables.size():
		variables.resize(id + 100)
	var prevVal = variables[id] if variables[id] != null else 0
	variables[id] = v
	if prevVal != v:
		onVariableChange.emit(id,v)

func getActor(id:StringName) -> GameActor:
	for a in actors:
		if (a.id == id):
			return a
	# Not found, initialize
	var a = GameActor.new(id)
	actors.append(a)
	return a

func _serialize():
	var save_dict = {
		"actors" : _serializeActors(),
		"party" : party._serialize(),
		"switches" : switches,
		"variables" : variables,
		"characters" : _serializeCharacters()
	}
	return save_dict

func _serializeActors():
	var actorAry = []
	for a in actors: actorAry.append(a._serialize())
	return actorAry

func _serializeCharacters():
	var dict = {}
	var scene : Node3D = Global.getSceneRoot()
	for n in scene.get_children():
		if n is Character:
			dict[n.get_path()] = {
				"posx" : n.global_position.x,
				"posy" : n.global_position.y,
				"posz" : n.global_position.z,
				"rotx" : n.global_rotation.x,
				"roty" : n.global_rotation.y,
				"rotz" : n.global_rotation.z
			}
	return dict

func _deserialize(savedata : Dictionary):
	for key in savedata:
		match key:
			"actors":
				var ary = _deserializeActors(savedata[key])
				set(key, ary)
			"party":
				var p = GameParty.new()
				p._deserialize(savedata[key])
				set(key, p)
			"characters":
				_characters = savedata[key]
			_:
				set(key, savedata[key])

func _deserializeActors(data : Array):
	var ary = []
	for i in data:
		var _e = GameActor.new("")
		_e._deserialize(i)
		ary.append(_e)
	return ary

func _deserializeCharacters():
	if (_characters == null): return
	var scene : Node3D = Global.getSceneRoot()
	print(Global.State.getSwitch(0))
	for n in scene.get_children():
		if n is Character:
			if n is NPC:
				n.refreshPage()
			var path = "/"+n.get_path().get_concatenated_names()
			if _characters.has(path):
				var e = _characters[path]
				var pos = Vector3(e["posx"],e["posy"],e["posz"])
				var rot = Vector3(e["rotx"],e["roty"],e["rotz"])
				n.global_position = pos
				n.global_rotation = rot
				n.target_velocity = Vector3.ZERO
	_characters = null
