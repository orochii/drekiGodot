extends BaseOption
class_name DropdownOption

@export var option:OptionButton

# label
# options
# wire to variable
var values = []
var _active = false

func setup(text:String, options:Dictionary={true:"Yes",false:"No"}):
	label.text = text
	values.clear()
	option.clear()
	for k in options:
		option.add_item(options[k])
		values.append(k)
	onVisible()

func _on_option_button_item_selected(index):
	if(!_active): return
	var v = values[index]
	self.setValue(v)
	setActive(false)
	Global.Audio.playSFX("decision")

func onActive():
	#get_viewport().gui_release_focus()
	UIUtils.setVNeighbors([option])
	option.grab_focus()
	# How do I open the dropdown? ._.
	option.show_popup()

func _process(delta):
	if(!visible || !active): return
	if(Input.is_action_just_pressed("action_cancel")):
		setActive(false)

func onVisible():
	var v = self.getValue()
	var i = values.find(v)
	if(i != -1):
		_active = false
		option.select(i)
	_active = true
