extends Resource
class_name Status

@export_category("Display")
@export var name : String
@export var description : String
@export var icon : Texture2D
@export var displayRating : int

@export_category("Behavior")
@export_flags("Non Resistance", "HP0", "No EXP", "No Evade") var flags = 0
@export var restriction : int # None, NoMagic, AtkEnemy, AtkAlly, CantMove

@export_category("Effects over Time")
@export var eotActivation : int # TURN,MILLISECONDS
@export var eotInterval : int
# effects list: DoT and what else? (hp,mp)

@export_category("Constant Effects")
# Might change towards just having a full list of effects, akin to VXA's features
@export var statEffects : Array[StatEffect]
@export var elementAffinityChange : Array[ElementAffinity]
@export var statusRemove : Array[Status]

@export_category("Release Conditions")
@export var releaseAtBattleEnd : bool
@export_range(0,1) var releaseOnDamageReceived : float
@export var releaseOnTurnsElapsed : int
@export_range(0,1) var releaseOnTurnsElapsedRate : float
