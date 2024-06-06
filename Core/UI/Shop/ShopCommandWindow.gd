extends BaseWindow

@export var buttons:Array[Button]
var lastSelected:Button

func _ready():
    super._ready()
    UIUtils.setHNeighbors(buttons)

func _process(delta):
    if _isActive():
        if Input.is_action_just_pressed("action_cancel"):
            Global.Audio.playSFX("cancel")
            get_parent().close()
        var focused = get_viewport().gui_get_focus_owner()
        if buttons.has(focused):
            lastSelected = focused
            repositionCursor(focused)
        else:
            if lastSelected != null:
                lastSelected.grab_focus()
            else:
                buttons[0].grab_focus()

func _isActive():
    if Global.UI.Config.visible: return false
    var p = get_parent() as ShopMenu
    return p.currentActiveScreen == self

func _on_buy_pressed():
    Global.Audio.playSFX("decision")
    var p = get_parent() as ShopMenu
    p.openShopMode(ShopMenu.EShopMode.BUY)

func _on_sell_pressed():
    Global.Audio.playSFX("decision")
    var p = get_parent() as ShopMenu
    p.openShopMode(ShopMenu.EShopMode.SELL)
