extends Control

@export var parent:ShopMenu
@export var itemEntry:ItemEntry
@export var description:RichTextLabel
@export var singlePrice:Control
@export var detailPrice:Control
@export var equipDetails:Control

var currentItem = null

func setItem(item:BaseItem, transactionMode:bool):
    currentItem = item
    # Set visible entry
    var _entry = GameInventoryEntry.new()
    _entry.id = item.getId()
    _entry.amount = Global.State.party.itemCount(_entry.id)
    itemEntry.setup(_entry)
    # Set description
    description.text = TextUtils.parseText(item.getDesc())
    # Set price
    var isSelling = parent.currentShopMode==ShopMenu.EShopMode.SELL
    if transactionMode==true:
        singlePrice.visible = false
        detailPrice.visible = true
        detailPrice.setItem(item, isSelling)
    else:
        singlePrice.visible = true
        detailPrice.visible = false
        singlePrice.setItem(item, isSelling)
    # Equip details
    if item is EquipItem:
        equipDetails.visible = true
        var equipItem:EquipItem = item as EquipItem
        equipDetails.setItem(equipItem)
    else:
        equipDetails.visible = false

func _process(delta):
    if _isActive():
        get_viewport().gui_release_focus()
        if Input.is_action_just_pressed("action_cancel"):
            Global.Audio.playSFX("cancel")
            setItem(currentItem,false)
            parent.goto(parent.itemList)
            return
        if Input.is_action_just_pressed("action_ok"):
            Global.Audio.playSFX("shop")
            # Execute transaction
            parent.doTransaction(currentItem, detailPrice.currentQuantity, detailPrice.getTotalPrice())
            # Return
            setItem(currentItem,false)
            parent.itemList.open()
            return
        # Up and down raise/lower quantity by 1
        if Global.Inputs.isRepeating("ui_up"):
            Global.Audio.playSFX("cursor")
            detailPrice.changeQuantity(1)
        if Global.Inputs.isRepeating("ui_down"):
            Global.Audio.playSFX("cursor")
            detailPrice.changeQuantity(-1)
        # Left and right raise/lower quantity by 10
        if Global.Inputs.isRepeating("ui_left"):
            Global.Audio.playSFX("cursor")
            detailPrice.changeQuantity(-10)
        if Global.Inputs.isRepeating("ui_right"):
            Global.Audio.playSFX("cursor")
            detailPrice.changeQuantity(10)

func _isActive():
    if Global.UI.Config.visible: return false
    return parent.currentActiveScreen == self
