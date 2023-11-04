extends NinePatchRect
class_name StateStackIcon

@export var stacks:Array[NinePatchRect]

var _statusState:StatusState = null

func setup(ss:StatusState):
	_statusState = ss
	refresh()

func refresh():
	if _statusState==null:
		for s in stacks: s.texture = null
		visible = false
	else:
		var status:Status = Global.Db.getStatus(_statusState.id)
		for i in range(stacks.size()):
			var s = stacks[i]
			s.visible = (i < _statusState.stack)
			s.texture = status.icon
		visible = true
