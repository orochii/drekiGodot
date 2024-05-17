extends StaticBody3D

@export var requiredBody:Node3D
@export var switchId:StringName = &""

# Shouldn't be using a switch for this. This should be using something else,
# like a temporary flag in the receiving body or something.

func _on_area_3d_body_entered(body:PhysicsBody3D):
	if body == null: return
	if body == requiredBody:
		#Global.State.setSwitch(switchId,true)
		var cc = body.get_children()
		for c in cc:
			c.set(&"currentActivator", self)

func _on_area_3d_body_exited(body):
	if body == null: return
	if body == requiredBody:
		#Global.State.setSwitch(switchId,false)
		var cc = body.get_children()
		for c in cc:
			c.set(&"currentActivator", null)
