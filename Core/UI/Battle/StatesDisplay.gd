extends HBoxContainer
class_name StatesDisplay

@export var baseStackIcon:StateStackIcon
@export var visibleStacks:int = 5

var allStacks:Array[StateStackIcon]
var battler:Battler = null

func _ready():
	baseStackIcon.setup(null)
	allStacks.append(baseStackIcon)
	for i in range(visibleStacks-1):
		var n:StateStackIcon = baseStackIcon.duplicate()
		n.setup(null)
		allStacks.append(n)
		self.add_child(n)

func setup(b:Battler):
	battler = b

func _process(delta):
	if(battler != null):
		var states = battler.battler.getSortedStates()
		for i in range(visibleStacks):
			var stack = allStacks[i]
			if(states.size() > i):
				var state = states[i]
				stack.setup(state)
			else:
				stack.setup(null)
