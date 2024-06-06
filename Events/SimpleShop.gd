extends BaseEvent

@export var speakerName:String = ""
@export_multiline var textLinesStart:Array[String] = ["Howdy!"]
@export_multiline var textLinesEnd:Array[String] = ["See ya!"]
@export var itemsToSell:Array[BaseItem] = []

func _run():
    var p = get_parent()
    for line in textLinesStart:
        await Global.UI.Message.showText(p, 2, speakerName, line)
    await Global.Scene.callShop(itemsToSell)
    for line in textLinesEnd:
        await Global.UI.Message.showText(p, 2, speakerName, line)
    