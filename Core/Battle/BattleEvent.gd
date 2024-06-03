extends Resource
class_name BattleEvent

enum ERepeatSpan { BATTLE,TURN,TICK }

@export var activation : ERepeatSpan
@export var conditions : Array[EventPageCondition]
@export var event : GDScript

var running:bool = false

func check() -> bool:
	for c in conditions:
		if c.check(self)==false: return false
	return true

func execute():
	#
	if running: return
	# Setup
	Global.Battle.runningEvents.append(self)
	running = true
	# Run
	var ev = RefCounted.new()
	ev.set_script(event)
	await ev.run(self)
	# End
	await Global.Ev.wait(0.1)
	if is_instance_valid(Global.Battle):
		Global.Battle.runningEvents.erase(self)
	running = false
