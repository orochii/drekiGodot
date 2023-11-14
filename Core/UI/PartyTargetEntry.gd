extends Button
class_name PartyTargetEntry

@export_group("Can Use")
@export var canUse:Control
@export var nameText:Label
@export var lpText:Label
@export var mpText:Label
@export var statusIcons:Array[NinePatchRect]
@export var useEffect:GPUParticles2D
@export_group("Can Equip")
@export var canEquip:Control
@export var equipLabel:Label

var onPressed:Callable
var actor:GameActor

func setupUse(id:StringName):
	canUse.visible=true
	canEquip.visible=false
	actor = Global.State.getActor(id)
	refreshUse()

func refreshUse():
	nameText.text = actor.getName()
	lpText.text = "%d" % actor.currHP
	mpText.text = "%d" % actor.currMP
	var ary:Array[StatusState] = actor.getSortedStates()
	for i in range(statusIcons.size()):
		var si = statusIcons[i]
		if i < ary.size():
			var status = Global.Db.getStatus(ary[i].id)
			si.texture = status.icon
		else:
			si.texture = null

func setupEquip(id:StringName,data:BaseItem):
	canUse.visible=false
	canEquip.visible=true
	actor = Global.State.getActor(id)
	nameText.text = actor.name
	if data is EquipItem:
		var equip = data as EquipItem
		if actor.canEquip(equip):
			equipLabel.text = "Can equip"
			return
	equipLabel.text = "Can't equip"

func _on_pressed():
	# Call use from parent (to support multitarget uses).
	if onPressed.is_valid():
		onPressed.call(self)

func triggerUseEffect():
	if useEffect != null:
		useEffect.emitting = true
