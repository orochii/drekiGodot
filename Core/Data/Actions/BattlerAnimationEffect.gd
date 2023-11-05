extends BaseEffect
class_name BattlerAnimationEffect

@export var state:StringName
@export var loop:bool
@export var waitForEnd:bool
@export var applyOnTarget:bool

# In-battle action execution
func execute(action:BattleAction):
	# action.battler
	if applyOnTarget:
		for target in action.targets:
			target.playPose(state,loop)
	else:
		action.battler.playPose(state,loop)
		if waitForEnd:
			await action.battler.onAnimationWaitEnd

# Data change
func apply(user:GameBattler, target:GameBattler):
	# any randomness occurs here, not on calcEffect
	pass

func calcEffect(user:GameBattler, target:GameBattler):
	# any calculation here must be deterministic
	return {}
