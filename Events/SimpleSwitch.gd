extends BaseEvent

@export var switchId:int
@export var deactivateOnEnabled:bool
@export var model:CharModel
@export var blendTime:float = 0.6
@export var waitTime:float = 0.6
@export var elevator:Node
@export var camPosition:Node3D
@export var panningTime:float = 1.0
@export var panningWait:float = 2.0

func _run():
	var switch = Global.State.getSwitch(switchId)
	if deactivateOnEnabled && switch: return
	# Move the thing!
	if model != null: model.setPose(!switch,blendTime)
	await get_tree().create_timer(waitTime).timeout
	# Pan towards node
	Global.Camera.panTowards(camPosition,panningTime)
	while Global.Camera.isPanning(): await get_tree().process_frame
	# Set switch
	Global.State.setSwitch(switchId,!switch)
	await get_tree().create_timer(panningWait).timeout
	# Go back to player
	Global.Camera.resetTarget(panningTime)
	while Global.Camera.isPanning(): await get_tree().process_frame

func setup(immediate:bool=false):
	var switch = Global.State.getSwitch(switchId)
	if model != null: model.setPose(switch)
	if elevator != null: elevator.moveTo(switch,immediate)
