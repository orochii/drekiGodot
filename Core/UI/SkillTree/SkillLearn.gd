extends Control

@export var skillInfo:SkillInfo
@export var apCostLabel:Label
@export var particles:GPUParticles2D

var parent = null
var currentSlot = null

func _ready():
    visible = false

func _process(delta):
    if Global.UI.Config.visible: return
    if !visible: return
    #
    if Input.is_action_just_pressed("action_cancel"):
        Global.Audio.playSFX("cancel")
        close()
        return
    if Input.is_action_just_pressed("action_ok"):
        if tryLearn():
            Global.Audio.playSFX("item")
            particles.position = currentSlot.position + Vector2(8,8)
            particles.restart()
            particles.emitting = true
            parent.lastLearned = currentSlot.slot.gridPosition
            parent.refresh()
            parent.parentScreen.skillList.refresh()
            close()
        else:
            Global.Audio.playSFX("buzzer")
        return

func setup(_parent,_currentSlot):
    parent = _parent
    parent.active = false
    currentSlot = _currentSlot
    skillInfo.setup(currentSlot.actor, currentSlot.currentSkill)
    if currentSlot.maxed:
        apCostLabel.text = "--"
    else:
        apCostLabel.text = "%d" % currentSlot.currentApCost
    await get_tree().process_frame
    visible = true
    #
func tryLearn():
    return currentSlot.actor.learnSlot(currentSlot.slot)
func close():
    visible = false
    parent.active = true