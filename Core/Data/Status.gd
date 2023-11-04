extends Resource
class_name Status

@export_category("Display")
@export var name : String
@export var description : String
@export var icon : Texture2D
@export var displayRating : int

@export_category("Behavior")
@export_flags("Non Resistance", "Incapacitated", "No EXP", "No Evade") var flags = 0
@export var restriction : Global.ERestriction # None, NoMagic, AtkEnemy, AtkAlly, CantMove

@export_category("Effects over Time")
@export var eotActivation : Global.EStatusActivation
@export var eotInterval : int
@export var eotSequence : Array[BaseEffect]

@export_category("Constant Effects")
@export var features : Array[BaseFeature]
@export var statusRemove : Array[Status]

@export_category("Release Conditions")
@export var releaseAtBattleEnd : bool
@export_range(0,1) var releaseOnDamageReceived : float
@export var releaseOnTurnsElapsed : int
@export_range(0,1) var releaseOnTurnsElapsedRate : float

func getId():
	# res://Data/Status/Death.tres
	var len = resource_path.length()
	var dirlen = "res://Data/Status/".length()
	var extlen = ".tres".length()
	return resource_path.substr(dirlen, len-dirlen-extlen)
