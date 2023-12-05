extends BaseEvent

@export var cooldownTime:float = 5.0
@export var navigator:NavigationAgent3D
@export var animator:AnimationPlayer

func _run():
	navigator.setEnabled(false)
	animator.play("blink")
	await get_tree().create_timer(cooldownTime).timeout
	navigator.setEnabled(true)
	animator.play("RESET")
	get_parent().setLocalVar("freeze", false)
	get_parent().refreshPage()
