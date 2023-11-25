extends Node3D
class_name BaseEvent

enum EActivation { INTERACT, PLAYER_TOUCH, EVENT_TOUCH, AUTOSTART, PARALLEL }

@export_group("Visuals")
@export var graphic : Spritesheet
@export var collision: bool = true
@export_group("Behavior")
@export var activation : EActivation
@export var loop : bool
@export var conditions : Array[EventPageCondition]

var looping : bool = false

func check() -> bool:
	for c in conditions:
		if c.check()==false: return false
	return true

func execute():
	if activation != EActivation.PARALLEL: Global.Ev.add(self)
	looping = loop
	await _run()
	while looping:
		await _run()
	await Global.Ev.wait(0.1)
	Global.Ev.remove(self)

func _run():
	pass

func setup(immediate:bool=false):
	pass
