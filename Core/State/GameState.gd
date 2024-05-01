extends Object
class_name GameState
#						J  F  M  A  M  J  J  A  S  O  N  D  U
const MAX_MONTHDAYS = [28,28,28,28,28,28,28,28,28,28,28,28,28]
const WEEKDAY_NAMES = ["Raidō","Fehu","Eiwaz","Ūruz","Algiz","Mannaz","Sōwilō"]
const MONTH_NAMES = ["Tēwaz","Gebō","Ehwaz","Yngwaz","Jēra","Perþō","Þurisaz","Kenaz","Wunjō","Ōþala","Naudiz","Isaz", "Haglaz"]

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
var localVars : Dictionary = {}
# map state
var _characters = null
var lastSceneName : String = ""
var targetGate : int = -1
var cameraAngle : float = 0
# system state
#[5,21,30,22,9,500]
#[9,11,5,6,7,511]
var gameTime:Dictionary = { "h":9,"m":0,"s":0,"day":6,"month":7,"year":511 }
var playTime:float = 0
var stepsTaken:int = 0
var currentTroop:EnemyTroop = null
var currentBattleback:String = ""
# Screenshot differentiator helper (why time doesn't have millis? :C)
var lastTime = null
var count = 0

func initialize():
	party = GameParty.new()
	switches.resize(MAX_SWITCHES)
	variables.resize(MAX_VARIABLES)

#region Switch/Variable Operations
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

func getLocalVar(key:String, name:StringName):
	var fullKey = "%s;;%s" % [key, name]
	if localVars.has(fullKey):
		return localVars[fullKey]
	return false
func setLocalVar(key:String, name:StringName, val:bool):
	var fullKey = "%s;;%s" % [key, name]
	localVars[fullKey] = val
#endregion

#region Time operations
func setDate(y,m,d):
	gameTime["year"] = y
	gameTime["month"] = m % MONTH_NAMES.size()
	gameTime["day"] = d % MAX_MONTHDAYS[gameTime["month"]]
func setTime(h,m,s):
	gameTime["h"] = h % 24
	gameTime["m"] = m % 60
	gameTime["s"] = s % 60
func advanceTime(ss):
	if ss <= 0: return
	gameTime["s"] = gameTime["s"] + ss
	if gameTime["s"] >= 60:
		var minutesElapsed = floori(gameTime["s"]) / 60
		gameTime["s"] = gameTime["s"] - (minutesElapsed*60)
		gameTime["m"] = gameTime["m"] + minutesElapsed
		if gameTime["m"] >= 60:
			var hoursElapsed = gameTime["m"] / 60
			gameTime["m"] = gameTime["m"] - (hoursElapsed*60)
			gameTime["h"] = gameTime["h"] + hoursElapsed
			if gameTime["h"] >= 24:
				var daysElapsed = gameTime["h"] / 24
				gameTime["h"] = gameTime["h"] - (daysElapsed*24)
				gameTime["day"] = gameTime["day"] + daysElapsed
				while gameTime["day"] >= MAX_MONTHDAYS[gameTime["month"]]:
					gameTime["day"] -= MAX_MONTHDAYS[gameTime["month"]]
					gameTime["month"] = gameTime["month"] + 1
					if gameTime["month"] >= MONTH_NAMES.size():
						gameTime["month"] = 0
						gameTime["year"] += 1
func advanceTimeBy(t:Dictionary):
	var ss = 0
	if t.has("s"): ss += t["s"]
	if t.has("m"): ss += t["m"]*60
	if t.has("h"): ss += t["h"]*3600
	if t.has("day"): ss += t["day"]*(3600*24)
	advanceTime(ss)
	# Month and year can be done separately
	if t.has("month"):
		gameTime["month"] = gameTime["month"] + t.has("month")
		if gameTime["month"] >= MONTH_NAMES.size():
			var yearsElapsed = gameTime["month"] / MONTH_NAMES.size()
			gameTime["month"] -= yearsElapsed*MONTH_NAMES.size()
			gameTime["year"] += yearsElapsed
	if t.has("year"): gameTime["year"] += t["year"]
func daysElapsed():
	var dd = gameTime["year"] * daysPerYear() + gameTime["day"]
	for i in gameTime["month"]:
		dd += MAX_MONTHDAYS[i]
	return dd
func daysPerYear():
	var t = 0
	for m in MAX_MONTHDAYS: t += m
	return t
func weekday():
	var d = daysElapsed()
	return d % WEEKDAY_NAMES.size()
#endregion

func getActor(id:StringName) -> GameActor:
	for a in actors:
		if (a.id == id):
			return a
	# Not found, initialize
	var a = GameActor.new(id)
	actors.append(a)
	return a

func getSaveTimestamp():
	var time = Time.get_datetime_dict_from_system()
	return "%d/%d/%d %02d:%02d:%02d" % [time.year, time.month, time.day, time.hour, time.minute, time.second]

func getScreenshotTimestamp():
	var time = Time.get_datetime_dict_from_system()
	var dup = false
	if lastTime != null:
		if lastTime.year==time.year:
			if lastTime.month==time.month:
				if lastTime.day==time.day:
					if lastTime.hour==time.hour:
						if lastTime.minute==time.minute:
							if lastTime.second==time.second:
								dup = true
	if dup:
		count += 1
	else:
		count = 0
	lastTime = time
	return "%d-%d-%d_%02d%02d%02d_%d" % [time.year, time.month, time.day, time.hour, time.minute, time.second, count]

func formatPlayTime(seconds:float) -> String:
	var ts = floori(seconds)
	var milli = floor((seconds - ts) * 1000)
	var s = ts % 60
	var tm = ts / 60
	var m = tm % 60
	var h = tm / 60
	return "%02d:%02d:%02d.%03d" % [h,m,s,milli]

#region Serialization
func _serialize():
	var save_dict = {
		"actors" : _serializeActors(),
		"party" : party._serialize(),
		"switches" : switches,
		"variables" : variables,
		"localVars" : localVars,
		"characters" : _serializeCharacters(),
		"lastSceneName" : lastSceneName,
		"cameraAngle" : Global.Camera.currRotation.y,
		#
		"gameTime" : gameTime,
		"playTime" : playTime,
		"stepsTaken" : stepsTaken,
		"timestamp" : getSaveTimestamp()
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
				"rotz" : n.global_rotation.z,
				"erased" : n.erased,
			}
	return dict

func _deserialize(savedata : Dictionary):
	for key in savedata:
		match key:
			"actors":
				var ary = _deserializeActors(savedata[key])
				actors = ary
			"party":
				var p = GameParty.new()
				p._deserialize(savedata[key])
				party = p
			"characters":
				_characters = savedata[key]
			_:
				set(key, savedata[key])

func _deserializeActors(data : Array):
	var ary:Array[GameActor] = []
	for i in data:
		var _e = GameActor.new("")
		_e._deserialize(i)
		ary.append(_e)
	return ary

func _deserializeCharacters():
	if (_characters == null): return
	var scene : Node3D = Global.getSceneRoot()
	for n in scene.get_children():
		if n is Character:
			var path = "/"+n.get_path().get_concatenated_names()
			if _characters.has(path):
				var e = _characters[path]
				var pos = Vector3(e["posx"],e["posy"],e["posz"])
				var rot = Vector3(e["rotx"],e["roty"],e["rotz"])
				n.global_position = pos
				n.global_rotation = rot
				n.target_velocity = Vector3.ZERO
				if e.has("erased"): n.setErased(e["erased"])
			if n is NPC:
				n.refreshPage()
		if n is Trigger:
			var path = "/"+n.get_path().get_concatenated_names()
			if _characters.has(path):
				var e = _characters[path]
				#if e.has("localVars"): n.localVars = e["localVars"]
			n.refreshPage()
	_characters = null
#endregion
