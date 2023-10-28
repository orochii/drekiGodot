extends BaseEvent

@export var troop:EnemyTroop

func _run():
	var p = get_node("/root/Node3D/Player")
	await Global.UI.Message.showText(self, 8, "", "boo!")
	await Global.UI.Message.showText(p, 8, "", "oh no, moles .-.")
	await Global.Scene.callBattle(troop)
	await Global.UI.Message.showText(self, 8, "", "hahaha (?)")
