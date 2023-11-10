extends BaseItem
class_name EquipItem

@export_group("Visual")
@export var weaponSprite : Texture2D
@export var gripOffset : Vector2i

@export_group("Equip")
@export var slot : Global.EquipSlot
@export var flags : Array[Global.EquipKind]
@export var features : Array[BaseFeature]

# ARMS must give a skill. 
# When they don't it will default to either punch or kick.
@export_group("Special")
@export var skill : BaseSkill
