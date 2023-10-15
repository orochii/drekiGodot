class_name Interpreter

var running = []

func isBusy():
	return running.size() > 0

func add(ev : BaseEvent):
	if !running.has(ev):
		running.append(ev)

func remove(ev : BaseEvent):
	if running.has(ev):
		running.erase(ev)

func wait(time : float):
	await Global.UI.get_tree().create_timer(time).timeout
