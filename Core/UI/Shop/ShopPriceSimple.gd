extends Control

@export var priceLabel:Label

var currentItem:BaseItem
var isCurrentlySelling:bool

func setItem(item:BaseItem, isSelling:bool):
    if item==null:
        visible = false
        return
    visible = true
    currentItem = item
    isCurrentlySelling = isSelling
    #
    priceLabel.text = "%d" % getPrice()

func getPrice():
    return Global.State.party.getItemPrice(currentItem.price, isCurrentlySelling)