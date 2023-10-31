extends Control
class_name PartyMemberDisplay

@export var positionIcon : NinePatchRect
@export var faceGraphic : NinePatchRect
@export var nameLabel : Label
@export var classLabel : Label
@export var levelLabel : Label
@export var nextLabel : Label
@export var lpLabel : Label
@export var mpLabel : Label
# TODO: Status

var index : int = 0
var actor : GameActor = null
var parentMenu : PartyListSpawner = null

func setActor(i:int, a : GameActor):
	index = i
	actor = a
	refresh()

func refresh():
	if actor != null:
		var data : Actor = actor.getData()
		positionIcon.region_rect.position.y = actor.position * 32
		faceGraphic.texture = data.faceGraphic
		nameLabel.text = actor.name
		classLabel.text = data.jobName
		levelLabel.text = "%d" % actor.level
		nextLabel.text = "%d" % actor.getRemainingNextLvlExp()
		lpLabel.text = "%d/%d" % [actor.currHP, actor.getMaxHP()]
		mpLabel.text = "%d/%d" % [actor.currMP, actor.getMaxMP()]

func _on_pressed():
	if(parentMenu==null):return
	Global.Audio.playSFX("decision")
	parentMenu.showSubmenu(index)
	parentMenu.setFocus()

func setActive(v:bool):
	faceGraphic.active = v
