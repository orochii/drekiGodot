extends BaseEvent

var _done = false

func _run():
	var p = getPlayer()
	if !_done:
		# Wait
		p.state = &"base"
		await get_tree().create_timer(1).timeout
		p.state = &"downFace"
		await get_tree().create_timer(0.5).timeout
		p.state = &"sit"
		await get_tree().create_timer(1).timeout
		_done = true
	
	# Show options
	Global.UI.Message.setOptions(&"options", ["Retry","Load","Give up"], 2)
	await get_tree().process_frame
	await Global.UI.Message.showText(p, 8, "", "Retry battle?")
	
	var v = Global.State.getVariable(&"options")
	match v:
		0: # Retry
			# Retry last battle
			Global.restoreFromRetry()
			looping = false
		1: # Load
			# Call load menu
			Global.Scene.askPause(Global.UI.File)
			Global.UI.File.open(1,false)
			await get_tree().create_timer(0.5).timeout
			while Global.UI.File.visible:
				await get_tree().process_frame
			Global.Scene.askUnpause(Global.UI.File)
			await get_tree().create_timer(0.5).timeout
		2: # Return
			p.state = &"down"
			await get_tree().create_timer(1).timeout
			# TODO: Particles
			await get_tree().create_timer(1).timeout
			Global.Scene.goToRespawn()
			Global.State.party.recoverAll()
			looping = false
	await get_tree().process_frame
