extends BaseEffect
class_name SpawnVFXEffect

@export var visualEffectTemplate:PackedScene
@export var onePerEachTarget:bool = false
@export_enum("Don't wait","Wait","Wait in sequence") var waitMode:int = 1

func execute(action:BattleAction):
	if onePerEachTarget:
		var effectsToWaitFor = []
		for t in action.targets:
			var eff:VisualEffect = visualEffectTemplate.instantiate()
			eff.setup(action.battler, [t.graphic])
			# Wait mode
			match waitMode:
				1: # Append to list of effects to wait for
					effectsToWaitFor.append(eff)
				2: # Wait until this effect is done
					while shouldWait(eff):
						await action.battler.get_tree().process_frame
		# Wait until all effects are done
		if effectsToWaitFor.size() != 0:
			for eff in effectsToWaitFor:
				while shouldWait(eff):
					await action.battler.get_tree().process_frame
	else:
		var eff:VisualEffect = visualEffectTemplate.instantiate()
		var graphicTargets:Array[Node3D] = []
		for t in action.targets: graphicTargets.append(t.graphic)
		eff.setup(action.battler.graphic, graphicTargets)
		if waitMode != 0:
			# wait until effect is done
			while shouldWait(eff):
				await action.battler.get_tree().process_frame

func shouldWait(eff):
	if eff==null: return false
	if is_instance_valid(eff)==false: return false
	return eff.done==false
