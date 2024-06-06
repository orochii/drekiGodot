extends Control
class_name ScrollItemList

@export var container:Container
@export var scroll:Container
@export var equipEntryTemplate:PackedScene
@export var parentScreen:Node
@export var description:RichTextLabel
@export var cursor:AnimatedSprite2D
var equipEntries:Array
var slot:Global.EquipSlot
var actor:GameActor
var idx:int
var lastFocused=null

func _process(delta):
    if(is_visible_in_tree()==false):return
    if Global.UI.Config.visible: return
    # Scroll to focused control
    var focused = get_viewport().gui_get_focus_owner()
    if equipEntries.has(focused):
        scroll.ensure_control_visible(focused)
        if lastFocused != focused:
            if focused.data != null:
                description.text = focused.data.getDesc()
            else:
                description.text = ""
            repositionCursor(focused)
            lastFocused = focused
	# Close
    if(Input.is_action_just_pressed("action_cancel")):
        Global.Audio.playSFX("cancel")
        close()
		#equipScreen.onListClose()

func close():
    visible = false
    parentScreen.buttons[idx].grab_focus()
    await get_tree().process_frame
    parentScreen.active = true

func showMenu():
    if cursor != null: cursor.play("default")
    parentScreen.active = false
    visible = true
    if equipEntries.size() != 0:
        equipEntries[0].grab_focus()

func refreshList(_actor:GameActor,_idx):
    actor = _actor
    idx = _idx
    slot = Global.EquipSlot.SCROLL
    for e in equipEntries: e.queue_free()
    equipEntries.clear()
    var items : Array = Global.State.party.inventory
    for i in items:
        var item = Global.Db.getItem(i.id)
        if filter(item):
            var inst = equipEntryTemplate.instantiate()
            inst.setup(i,null)
            inst.pressed.connect(onEquip)
            container.add_child(inst)
            equipEntries.append(inst)
    # Add remove
    var _remove = equipEntryTemplate.instantiate()
    _remove.setup(null,null)
    _remove.pressed.connect(onEquip)
    container.add_child(_remove)
    equipEntries.append(_remove)
    # Update neighbor stuff
    UIUtils.setVNeighbors(equipEntries)
    lastFocused = null
    description.text = ""

func filter(item:BaseItem):
    if item is EquipItem:
        var e = item as EquipItem
        if e.slot != slot: return false
        if actor.canEquip(e): return true
    return false

func onEquip():
    var focused = get_viewport().gui_get_focus_owner()
    if equipEntries.has(focused):
        Global.Audio.playSFX("equip")
        parentScreen.equip(idx,focused.data)
        close()

func repositionCursor(focused):
    if cursor != null: 
        if focused != null:
            cursor.global_position = focused.global_position + Vector2(8,8)
            cursor.visible = true
        else:
            cursor.visible = false
