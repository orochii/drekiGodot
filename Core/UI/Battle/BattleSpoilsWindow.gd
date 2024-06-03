extends Control
class_name BattleSpoilsWindow

@export var entryTemplate:PackedScene
@export var scroll:ScrollContainer
@export var container:Container
@export var helpText:RichTextLabel

var _entries = []
var _treasures = []

func setup(treasures):
	_treasures = treasures
	for item in _treasures:
		var itemData:BaseItem = item as BaseItem
		var inst = entryTemplate.instantiate()
		inst.setup(itemData.getName(), itemData.icon)
		_entries.append(inst)
		container.add_child(inst)
	UIUtils.setGridNeighbors(_entries,2)

func selectFirst():
	if(_entries.size() != 0): _entries[0].grab_focus()

func _process(delta):
	if !visible: return
	var focused = get_viewport().gui_get_focus_owner()
	var idx = _entries.find(focused)
	if idx >= 0:
		scroll.ensure_control_visible(focused)
		_refreshHelp(_treasures[idx])

func _refreshHelp(item):
	helpText.text = TextUtils.parseText(item.getDesc())
