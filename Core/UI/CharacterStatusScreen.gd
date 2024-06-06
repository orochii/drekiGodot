extends BaseWindow

@export var charStats : CharacterStats
@export var listSpawner:PartyListSpawner
@export var buttons:Array[Button]
@export var scrollList:ScrollItemList
@export_group("Visuals")
@export var scroll1Item:GenericItemEntry
@export var scroll2Item:GenericItemEntry
@export var fylgjaItem:GenericItemEntry
@export var positionButton:Button

var currIdx = 0
var active:bool = false

# PAYLOAD: [partyIdx]
func showTask(payload):
	scrollList.visible = false
	if(payload != null):
		currIdx = payload[0]
		if(listSpawner != null): listSpawner.reposition(currIdx)
	var members = Global.State.party.getMembers()
	var actor = Global.State.getActor(members[currIdx])
	charStats.setup(actor)
	UIUtils.setVNeighbors(buttons)
	_refreshAll()
func setFocus():
	buttons[0].grab_focus()
	active = true
func hideTask():
	pass
func reset():
	pass

func _process(delta):
	if Global.UI.Config.visible: return
	get_parent().active = active
	if !active: return
	if(get_parent().visible==false): return
	if(get_parent().active==false): return
	var focused = get_viewport().gui_get_focus_owner()
	if buttons.has(focused):
		repositionCursor(focused)
	if(moveLeft()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(3,[currIdx])
		return
	if(moveRight()):
		Global.Audio.playSFX("cursor")
		get_parent().get_parent().setScreen(2,[currIdx])
		return
	if(cycleLeft()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size - 1) % size
		get_parent().get_parent().setScreen(1,[newIdx])
		return
	if(cycleRight()):
		var size = Global.State.party.getMembers().size()
		var newIdx = (currIdx + size + 1) % size
		get_parent().get_parent().setScreen(1,[newIdx])
		return

func cycleLeft():
	return Input.is_action_just_pressed("cycle_left")
func cycleRight():
	return Input.is_action_just_pressed("cycle_right")

func moveLeft():
	return false #Input.is_action_just_pressed("cycle_left")
func moveRight():
	return Input.is_action_just_pressed("action_extra")

func _refreshAll():
	_refreshScrolls()
	_refreshPosition()
	_refreshFylgja()
func _refreshScrolls():
	_refreshScroll(0, scroll1Item)
	_refreshScroll(1, scroll2Item)
func _refreshScroll(idx:int, entry:GenericItemEntry):
	var e = charStats.actor.getScroll(idx) as EquipItem
	if e != null:
		entry.setup(e.getName(), e.icon)
	else:
		entry.setup("--", null)
func _refreshFylgja():
	fylgjaItem.setup("--", null)
func _refreshPosition():
	var _pos = charStats.actor.getPosition()
	positionButton.setPosition(_pos)

func equip(idx,data):
	match idx:
		0:
			charStats.actor.equipScroll(0, data)
			_refreshScroll(0, scroll1Item)
		1:
			charStats.actor.equipScroll(1, data)
			_refreshScroll(1, scroll2Item)
		2:
			print("TODO: Fylgja")

# === Buttons
func _on_scroll_1_pressed():
	scrollList.refreshList(charStats.actor,0)
	scrollList.showMenu()

func _on_scroll_2_pressed():
	scrollList.refreshList(charStats.actor,1)
	scrollList.showMenu()

func _on_fylgja_pressed():
	pass # Replace with function body.

func _on_position_pressed():
	Global.Audio.playSFX("decision")
	match charStats.actor.getPosition():
		0:
			charStats.actor.setPosition(1)
		1:
			charStats.actor.setPosition(0)
	_refreshPosition()
