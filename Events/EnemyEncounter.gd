extends BaseEvent

@export var troop:EnemyTroop

func _run():
	var p = getPlayer()
	#await Global.UI.Message.showText(self, 8, "", "boo!")
	#await Global.UI.Message.showText(p, 8, "", "oh no, moles .-.")
	#await Global.Scene.callBattle(troop)
	#await Global.UI.Message.showText(self, 8, "", "hahaha (?)")
	print("Battle: %s" % troop.resource_name)
	# call battle
	await Global.Scene.callBattle(troop)
	match Global.Scene.battleResult:
		BattleManager.EBattleResult.WIN:
			# erase
			var _parent = get_parent()
			if _parent.has_method("setErased"):
				_parent.setErased(true)
		BattleManager.EBattleResult.LOSE:
			Global.Scene.callGameOver()
		_:
			get_parent().setLocalVar("freeze", true)
			get_parent().refreshPage()
