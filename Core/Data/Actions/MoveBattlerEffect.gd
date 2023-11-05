extends BaseEffect
class_name MoveBattlerEffect

const MAX_VALUE = 9999

@export_enum("User", "Targets") var target: int
@export_enum("Home", "Targets") var reference: int
@export var referencePosition: Vector3
@export var selfOffset: Vector3
@export var positionOffset:Vector3
@export var waitUntilFinished:bool = true

func execute(action:BattleAction):
	match reference:
		0:
			await doMove(action.battler,[action.battler])
		1:
			match target:
				0: # user
					await doMove(action.battler,action.targets)
				_: # targets
					for t in action.targets:
						doMove(t,[t])

func doMove(b:Battler,localTargets:Array[Battler]):
	# no targets
	if localTargets.size()==0: return
	# Get center
	var center:Vector3 = Vector3(0,0,0)
	for t in localTargets:
		var pos = t.homePosition
		center += pos
	center /= localTargets.size()
	# Get radius and height
	var radius = 0
	var height:float = 0
	for t in localTargets:
		var pos = t.homePosition
		var size = t.getSize()
		var dst = center.distance_to(pos) + (size.x / 2)
		if radius < dst: radius = dst
		if height < size.y: height = size.y
	# Calc self offset
	var selfSize = b.getSize()
	var offset = Vector3(selfSize.x,selfSize.y,selfSize.x) * selfOffset
	# Calculate position
	var moveOffset = Vector3(radius,height,radius) * referencePosition + offset + positionOffset
	var rotY = b.direction + 90
	var moveOffsetRotated = moveOffset.rotated(Vector3.UP,deg_to_rad(rotY))
	var movePosition = center + moveOffsetRotated
	# Execute movement
	b.goToPosition(movePosition)
	if waitUntilFinished:
		while b.moving():
			await b.get_tree().process_frame
