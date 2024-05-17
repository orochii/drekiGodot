extends BaseEffect
class_name JumpEffect

const MAX_VALUE = 9999

@export_enum("User", "Targets") var target: int
@export_enum("Home", "Targets") var reference: int = 1
@export var referencePosition: Vector3 = Vector3(0.8,0,0)
@export var selfOffset: Vector3 = Vector3(0.3,0,0)
@export var positionOffset:Vector3
@export var waitUntilFinished:bool = true
@export_category("Jump Params")
@export var time:float = 1.0
@export var height:float = 7.5
@export var jumpPose:StringName = &"jumpHigh"
@export var lookAt:bool = true

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
	var selfTargetting = localTargets.has(b)
	var radius = 0
	var height:float = 0
	if !selfTargetting:
		for t in localTargets:
			var pos = t.homePosition
			var size = t.getSize()
			var dst = center.distance_to(pos) + (size.x / 2)
			if radius < dst: radius = dst
			if height < size.y: height = size.y
	# Calc self offset
	var selfSize = b.getSize()
	var offset = Vector3(selfSize.x,selfSize.y,selfSize.x) * selfOffset
	if selfTargetting: offset = Vector3.ZERO
	# Calculate position
	var moveOffset = Vector3(radius,height,radius) * referencePosition + offset + positionOffset
	var rotY = b.direction + 90
	var moveOffsetRotated = moveOffset.rotated(Vector3.UP,deg_to_rad(rotY))
	var movePosition = center + moveOffsetRotated
	# Execute movement
	b.jump(movePosition,time,height,jumpPose,lookAt)
	if waitUntilFinished:
		while b.jumping():
			await b.get_tree().process_frame
