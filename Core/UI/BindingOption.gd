extends BaseOption
class_name BindingOption

@export var backPanel:Panel
@export var keyboardBindIcons:Array[NinePatchRect]
@export var gamepadBindIcons:Array[NinePatchRect]

var keyboardBinds:Array[InputEventKey]
var gamepadBinds:Array[InputEvent]
var exiting:bool = false
var currIdx:int = 0

func setup(text:String, actionName:StringName):
	label.text = text
	_property = actionName
	readEvents()

func readEvents():
	var events = InputMap.action_get_events(_property)
	#Global.Db.ignoreKeyForRebind
	keyboardBinds.clear()
	gamepadBinds.clear()
	for ev in events:
		if ev is InputEventKey:
			var key = ev as InputEventKey
			#key.physical_keycode
			if !Global.Db.ignoreKeyForRebind.has(key.physical_keycode):
				keyboardBinds.append(key)
		elif ev is InputEventJoypadButton:
			var button = ev as InputEventJoypadButton
			#button.button_index
			#button.pressure
			if !Global.Db.ignoreButtonForRebind.has(button.button_index):
				gamepadBinds.append(ev)
		elif ev is InputEventJoypadMotion:
			var axis = ev as InputEventJoypadMotion
			#axis.axis
			#axis.axis_value
			if !Global.Db.ignoreAxisForRebind.has(axis.axis):
				gamepadBinds.append(ev)
	# Refresh visuals
	refreshVisuals()

func refreshVisuals():
	# Refresh keyboard icons
	for i in range(keyboardBindIcons.size()):
		var icon = keyboardBindIcons[i]
		if i < keyboardBinds.size():
			var ev = keyboardBinds[i]
			icon.texture = Global.Db.iconLibrary.getEventBindIcon(ev)
		else:
			icon.texture = null
	# Refresh gamepad icons
	for i in range(gamepadBindIcons.size()):
		var icon = gamepadBindIcons[i]
		if i < gamepadBinds.size():
			var ev = gamepadBinds[i]
			icon.texture = Global.Db.iconLibrary.getEventBindIcon(ev)
		else:
			icon.texture = null

# TODO:
# - Make the darn interaction, which is what will be a painnnnnn...

func reassign(ev:InputEvent,bindsArray:Array,idx:int):
	# Add up some nulls, yeah. ><
	if(idx >= bindsArray.size()):
		bindsArray.resize(idx+1)
	# Remove old binding
	if(bindsArray[idx] != null): 
		InputMap.action_erase_event(_property, bindsArray[idx])
	# Add new binding
	bindsArray[idx] = ev
	if(ev != null): 
		InputMap.action_add_event(_property, ev)
	refreshVisuals()

func _input(event):
	if(is_visible_in_tree() && active && !exiting):
		if event is InputEventKey:
			var key = event as InputEventKey
			if !key.pressed: return
			if key.physical_keycode == KEY_ESCAPE && key.pressed:
				#await get_tree().process_frame
				exiting = true
			else:
				if(!Global.Db.ignoreKeyForRebind.has(key.physical_keycode)):
					key.physical_keycode = key.get_physical_keycode_with_modifiers()
					key.keycode = 0
					reassign(key,keyboardBinds,currIdx)
					exiting = true
		elif event is InputEventJoypadButton:
			var button = event as InputEventJoypadButton
			if !button.pressed: return
			if(!Global.Db.ignoreButtonForRebind.has(button.button_index)):
				reassign(button,gamepadBinds,currIdx)
				exiting = true
		elif event is InputEventJoypadMotion:
			var axis = event as InputEventJoypadMotion
			axis.axis_value = roundf(axis.axis_value)
			if abs(axis.axis_value) < 0.5: return
			if(!Global.Db.ignoreAxisForRebind.has(axis.axis)):
				reassign(axis,gamepadBinds,currIdx)
				exiting = true

func _process(delta):
	if !active: return
	if exiting:
		exiting = false
		setActive(false)

func _on_pressed():
	setActive(true)

func onActive():
	get_viewport().gui_release_focus()
	backPanel.self_modulate.a = 1

func onInactive():
	backPanel.self_modulate.a = 0

func onVisible():
	refreshVisuals()
