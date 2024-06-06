extends Control

@export var unitPriceLabel:Label
@export var quantityLabel:Label
@export var maxQuantityLabel:Label
@export var totalPriceLabel:Label

var currentItem:BaseItem
var isCurrentlySelling:bool
var unitPrice:int
var currentQuantity:int
var maxQuantity:int

func setItem(item:BaseItem, isSelling:bool):
    if item==null:
        visible = false
        return
    visible = true
    currentItem = item
    isCurrentlySelling = isSelling
    # Set
    unitPrice = getPrice()
    currentQuantity = 0
    var _itemCount = Global.State.party.itemCount(item.getId())
    if isSelling:
        maxQuantity = _itemCount
    else:
        var maxAllowed = maxi(99 - _itemCount, 0)
        var maxAfforded = 99 if unitPrice==0 else (Global.State.party.gold / unitPrice)
        maxQuantity = mini(maxAfforded, maxAllowed)
    #
    unitPriceLabel.text = "%d" % unitPrice
    maxQuantityLabel.text = "%d" % maxQuantity
    #_refreshQuantity()
    changeQuantity(1)

func changeQuantity(d:int):
    currentQuantity = clampi(currentQuantity + d, 1, maxQuantity)
    _refreshQuantity()

func getPrice():
    return Global.State.party.getItemPrice(currentItem.price, isCurrentlySelling)

func getTotalPrice():
    return unitPrice * currentQuantity

func _refreshQuantity():
    quantityLabel.text = "%d" % currentQuantity
    totalPriceLabel.text = "%d" % getTotalPrice()
