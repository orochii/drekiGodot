extends BaseFeature
class_name CounterFeature

@export var action:UseableSkill
@export var targetCounteredBattler:bool

func valid(observant:Battler,user:Battler,effect:BaseEffect,targets:Array[Battler]):
	# Default counter is for physical attacks from enemies.
	# Is this character being targeted.
	if targets.has(observant) == false:
		return false
	# Is user your enemy.
	if observant.battler.isEnemy(user.battler) == false:
		return false
	# Is the effect dealing damage
	if effect is ApplyBasicDamage:
		var damage = effect as ApplyBasicDamage
		# Is the effect physical (atkF)
		if damage.atkF > 0:
			return true
	return false
