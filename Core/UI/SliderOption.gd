extends BaseOption
class_name SliderOption

@export var slider:HSlider

# label
# min
# max
# scale (for floats, when !=1 then returns float)
# wire to variable

var _scale:float = 1

func setup(text:String, min:int, max:int, scale:float = 1):
	label.text = text
	slider.min_value = min
	slider.max_value = max
	slider.tick_count = max-min+1
	_scale = scale
	var v = self.getValue()
	if(_scale != 1): v /= _scale
	slider.set_value_no_signal(v)

func _on_h_slider_value_changed(value):
	var v = value
	if(_scale != 1): v *= _scale
	self.setValue(v)
	Global.Audio.playSFX("cursor")

func onActive():
	#get_viewport().gui_release_focus()
	UIUtils.setVNeighbors([slider])
	slider.grab_focus()

func _process(delta):
	if(!visible || !active): return
	if(Input.is_action_just_pressed("action_cancel")):
		setActive(false)
