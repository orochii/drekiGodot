extends Node
class_name MapManager

@export var music : SystemAudioEntry
@export var battleback : PackedScene
@export var gates : Array[Node3D]
@export var defaultFloorGate : FloorGate
@export var battlePositions : Node
@export var animatedComplements : Node

var allCharacters:Array = []

func _ready():
	Global.Map = self
	getAllCharacters()
	var floorGate = defaultFloorGate
	# Move character to gate
	if Global.State.targetGate >= 0 && Global.State.targetGate < gates.size():
		var p = Global.Player
		if p != null:
			var g = gates[Global.State.targetGate]
			if g is TeleportGate:
				var tg = g as TeleportGate
				if tg.floorGate != null: floorGate = tg.floorGate
			p.global_position = g.global_position
			if p is Player:
				p.global_rotation = g.global_rotation
		else:
			print("player not found? I guess it hasn't run _ready yet")
		Global.State.targetGate = -1
	# Look for a default floor gate, use stored visible layers only for loading.
	if (Global.State.visibleLayers > 0): 
		Global.Camera.setLayers(Global.State.visibleLayers)
		Global.State.visibleLayers = 0
	elif floorGate != null:
		floorGate.setLayers()
	# Set current music
	if music != null:
		Global.Audio.playBGM(music.getStreamName(), music.volume, music.pitch)
	if battleback != null:
		Global.State.currentBattleback = battleback.resource_path

func getNearestBattlePosition():
	var p : Node3D = Global.Player
	if battlePositions == null:
		return null
	var nearest = null
	var nearestDist = 0
	var positions = battlePositions.get_children()
	for pp in positions:
		if pp is Node3D:
			var pos = pp as Node3D
			var dst = p.global_position.distance_squared_to(pos.global_position)
			if nearest==null || dst < nearestDist:
				nearest = pos
				nearestDist = dst
	if nearest==null:
		return p
	return nearest

func setForBattle(v:bool):
	setAnimatedForBattle(v)
	setCharactersVisible(!v)

func setAnimatedForBattle(v:bool):
	if animatedComplements==null: return
	if v:
		animatedComplements.process_mode = Node.PROCESS_MODE_ALWAYS
	else:
		animatedComplements.process_mode = Node.PROCESS_MODE_INHERIT

func setCharactersVisible(v:bool):
	for c in allCharacters:
		c.visible = v

func getAllCharacters():
	allCharacters.clear()
	getChildrenCharacters(self)
func getChildrenCharacters(root:Node):
	var cs = root.get_children(true)
	for c in cs:
		if c is Sprite3D:
			allCharacters.append(c)
		getChildrenCharacters(c)
