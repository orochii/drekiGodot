extends Resource
class_name Status

@export_category("Display")
@export var icon : Texture2D
@export var displayRating : int
@export var statusPose : StringName = &""

@export_category("Behavior")
@export_flags("Non Resistance", "Incapacitated", "No EXP", "No Evade") var flags = 0
@export var restriction : Global.ERestriction # None, NoMagic, AtkEnemy, AtkAlly, CantMove

@export_category("Effects over Time")
@export var eotActivation : Global.EStatusActivation
@export var eotInterval : int
@export var eotSequence : Array[BaseEffect]

@export_category("Constant Effects")
@export var features : Array[BaseFeature]
@export var statusRemove : Array[StringName]

@export_category("Release Conditions")
@export var releaseAtBattleEnd : bool
@export_range(0,1) var releaseOnDamageReceived : float
@export var releaseOnTurnsElapsed : int
@export_range(0,1) var releaseOnTurnsElapsedRate : float

func getId():
	return Status.stripId(resource_path)

func getName():
	return getId()
func getDesc():
	return getId() + "_desc"

static func stripId(_path:String):
	# res://Data/Status/Death.tres
	var len = _path.length()
	var dirlen = "res://Data/Status/".length()
	var startext = _path.find(".tres")
	return _path.substr(dirlen, startext-dirlen)