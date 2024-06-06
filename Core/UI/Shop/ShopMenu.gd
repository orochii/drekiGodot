extends Control
class_name ShopMenu

enum EShopMode {BUY,SELL}

@export var shopCommand:Control
@export var itemList:Control
@export var details:Control
@export var goldAmountLabel:Label

var currentActiveScreen:Control = null
var currentShopMode:EShopMode = EShopMode.BUY
var availableItemsList:Array = []

func _ready():
    availableItemsList = Global.State.shopCurrentItems
    # TODO: Yes to all
    currentActiveScreen = shopCommand
    details.visible = false
    _refreshGold()

func _refreshGold():
    goldAmountLabel.text = "%d" % Global.State.party.gold

func close():
    Global.Scene.closeUI(self)

func goto(screen):
    currentActiveScreen = null
    _refreshGold()
    await get_tree().process_frame
    currentActiveScreen = screen

func openShopMode(mode:EShopMode):
    currentShopMode = mode
    # populate and focus on item list
    itemList.open()
    details.visible = true

func closeShopMode():
    currentActiveScreen = shopCommand
    # clear item list and focus on commands
    itemList.close()
    details.visible = false

func doTransaction(item,quantity,price):
    match currentShopMode:
        EShopMode.BUY:
            Global.State.party.gainItem(item.getId(),quantity)
            Global.State.party.loseGold(price)
        EShopMode.SELL:
            Global.State.party.loseItem(item.getId(),quantity)
            Global.State.party.gainGold(price)
