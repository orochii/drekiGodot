extends Control
class_name BattleActorSkillSelect

@export var skillList:SkillList
@export var helpText:RichTextLabel
@export var statusWindow:Node
@export var actorCommand:BattleActorCommand

func _ready():
	visible = false

func open():
	actorCommand.visible = false
	visible = true
	skillList.setup(actorCommand.currentBattler.battler)

func _process(delta):
	if !visible: return
	
	if Input.is_action_just_pressed("action_cancel"):
		goBack()

func goBack():
	visible = false
	actorCommand.visible = true
	actorCommand.selectLast()
