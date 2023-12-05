extends BaseEvent

@export var troop:EnemyTroop

func _run():
	var p = getPlayer()
	#await Global.UI.Message.showText(self, 8, "", "boo!")
	#await Global.UI.Message.showText(p, 8, "", "oh no, moles .-.")
	#await Global.Scene.callBattle(troop)
	#await Global.UI.Message.showText(self, 8, "", "hahaha (?)")
	
	# call battle
	await Global.Scene.callBattle(troop)
	if Global.Scene.battleResult == BattleManager.EBattleResult.WIN:
		# erase
		get_parent().setErased(true)
	else:
		get_parent().setLocalVar("freeze", true)
		get_parent().refreshPage()
