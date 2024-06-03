extends BaseEvent

@export var speakerName:String = ""
@export_multiline var textLines:Array[String] = ["Howdy!"]

func _run():
    var p = get_parent()
    for line in textLines:
        await Global.UI.Message.showText(p, 2, speakerName, line)