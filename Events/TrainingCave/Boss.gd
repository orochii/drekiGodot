extends BaseEvent

@export var troop:EnemyTroop
@export var blink:AnimationPlayer
@export var retreatPos:Node3D

func _run():
	var p = getPlayer()
	get_parent().lookTowards(p.global_position)
	# start
	var alreadyTried = get_parent().getLocalVar(&"tried")
	if !alreadyTried:
		await Global.UI.Message.showText(p, 2, "\\N[Hikari]", "Sorry, but I'll have to take care of you.")
	else:
		await Global.UI.Message.showText(p, 2, "\\N[Hikari]", "Here we go again.")
	# battle
	await Global.Scene.callBattle(troop)
	# end
	match Global.Scene.battleResult:
		BattleManager.EBattleResult.WIN:
			get_parent().setLocalVar(&"dead", true)
		BattleManager.EBattleResult.LOSE:
			Global.Scene.callGameOver()
		_:
			p.navigateTowards(retreatPos.global_position)
			while p.navigating==true: 
				await get_tree().process_frame
			await Global.UI.Message.showText(p, 2, "\\N[Hikari]", "I might need to revise my strategy...")
			get_parent().setLocalVar(&"tried", true)
