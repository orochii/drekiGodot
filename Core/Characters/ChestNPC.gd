@icon("res://Editor/chest.svg")
@tool
extends NPC

@export var item:BaseItem
@export var amount:int
@export var spritesheet : Spritesheet:
	set(value):
		spritesheet = value
		if Engine.is_editor_hint():
			refreshSprite()

func _ready():
	for p:BaseEvent in pages:
		p.set(&"item", item)
		p.set(&"amount", amount)
		p.graphic = spritesheet
	if Engine.is_editor_hint():
		refreshSprite()
	else:
		super._ready()

func refreshSprite():
	if spritesheet != null:
		var s:SpritesheetEntry = spritesheet.getSheet(&"base")
		if s != null:
			s.getFrame(graphic, 0, false)
	else:
		graphic.texture = null

func _process(delta):
	if Engine.is_editor_hint():
		return
	#super._process(delta)
func _physics_process(delta):
	if Engine.is_editor_hint():
		return
	super._physics_process(delta)
