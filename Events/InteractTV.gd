extends BaseEvent

@export var altCam:Camera3D

func _run():
    var p = get_parent()
    Global.Map.setCharactersVisible(false)
    altCam.make_current()
    await Global.UI.Message.showText(p, 2, "", "Doesn't seem to be anything interesting.")
    await Global.UI.Message.showText(p, 2, "", "...syke! It's the best game ever, \nDrekirkorkrokrokrokrorkorkrokrokr1!.")
    Global.Map.setCharactersVisible(true)
    Global.Camera.make_current()