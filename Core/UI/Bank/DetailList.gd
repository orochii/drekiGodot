extends ScrollContainer

@export var detailTemplate:PackedScene
@export var detailContainer:Container

var _currentLines = []

func _ready():
	refreshLines()

func refreshLines():
	for l in _currentLines:
		l.queue_free()
	_currentLines.clear()
	var lines = Global.State.bank.aggregateEntries()
	for l in lines:
		var inst = detailTemplate.instantiate()
		inst.setup(l,lines[l])
		_currentLines.append(inst)
		detailContainer.add_child(inst)