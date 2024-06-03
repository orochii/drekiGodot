extends BaseEffect
class_name IsolateEffect

@export_enum("User", "Targets", "All") var target: int
@export var value:bool

func execute(action:BattleAction):
	match target:
		0:
			action.battler.setIsolate(value)
		1:
			for t in action.targets:
				t.setIsolate(value)
		_:
			action.battler.setIsolate(value)
			for t in action.targets:
				t.setIsolate(value)
