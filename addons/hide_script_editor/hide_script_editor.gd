@tool
extends EditorPlugin

var dock
var refreshButton:Button
var itemList:ItemList
var searchField:LineEdit
var nodeRefs:Array
var _lastFound = 0
var _lastSearch = ""

func _enter_tree():
	# Initialization of the plugin goes here.
	dock = preload("res://addons/hide_script_editor/inspect_dock.tscn").instantiate()
	refreshButton = dock.get_node("Container/RefreshButton")
	itemList = dock.get_node("Container/ItemList")
	searchField = dock.get_node("Container/HBoxContainer/LineEdit")
	refreshButton.pressed.connect(refresh)
	searchField.text_submitted.connect(find)
	add_control_to_dock(DOCK_SLOT_LEFT_UR, dock)
	#
	set_scripts_button(false)

func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_control_from_docks(dock)
	dock.free()
	set_scripts_button(true)

func refresh():
	if itemList.item_activated.is_connected(_activate):
		itemList.item_activated.disconnect(_activate)
	# Clean
	itemList.clear()
	nodeRefs.clear()
	# Wait
	get_tree().process_frame
	# Generate
	var root = EditorInterface.get_base_control()
	_generate_list(root,0)
	itemList.item_activated.connect(_activate)

func find(text:String):
	if _lastSearch != text:
		_lastSearch = text
		_lastFound = 0
	for i in range(_lastFound+1,itemList.item_count):
		if _findInItem(text,i):
			itemList.select(i)
			itemList.ensure_current_is_visible()
			_lastFound = i
			return

func _findInItem(text:String,idx:int):
	var t = itemList.get_item_text(idx)
	if t.contains(text): return true
	var n = nodeRefs[idx]
	if n != null && is_instance_valid(n):
		if n is Button:
			var b = n as Button
			if b.text.contains(text): return true
		elif n is Label:
			var l = n as Label
			if l.text.contains(text): return true
		else:
			if n.has_method("has") && n.has("text"):
				if n.text.contains(text): return true
	return false

func _generate_list(root:Node,level):
	var _name = root.name
	var _level= ""
	for i in level: _level += " "
	itemList.add_item(_level+_name, null)
	nodeRefs.append(root)
	var cs = root.get_children()
	for c in cs:
		_generate_list(c,level+1)

func _activate(idx:int):
	print(nodeRefs[idx].get_path())
	nodeRefs[idx].visible = !nodeRefs[idx].visible

var _origtext = ""
var _origicon = null
var _origstyle= null
func set_scripts_button(v:bool):
	var p = "/root/@EditorNode@17120/@Panel@13/@VBoxContainer@14/@EditorTitleBar@15/@HBoxContainer@4053/Script"
	var n = get_node(p)
	if is_instance_valid(n):
		var b = n as Button
		if _origicon==null && b.icon != null:
			_origtext = b.text
			_origicon = b.icon
			_origstyle= b.theme
		if v:
			b.text = _origtext
			b.icon = _origicon
			b.theme= load("res://addons/hide_script_editor/invisibutton.tres")
		else:
			b.text = ""
			b.icon = null
			b.theme= _origstyle
		b.visible = true
		b.disabled = !v
