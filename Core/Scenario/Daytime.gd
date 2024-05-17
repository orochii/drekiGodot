extends DirectionalLight3D

const DAY_LENGTH : float = 24*3600.0

@export var rotatingObject : Node3D = null
@export var town : bool = true
@export var angleOffset : float = 0
@export var dayColor : Color
@export var dawnColor : Color
@export var environment : WorldEnvironment

func _ready():
	refreshAngle() # Replace with function body.

func _process(delta):
	refreshAngle()

func refreshAngle():
	var t = Global.State.gameTime
	var s = t["s"]+t["m"]*60+t["h"]*3600
	var pp = (s / DAY_LENGTH)
	var p = pp * 360
	if rotatingObject != null: 
		if town:
			var angle = +p+angleOffset
			rotatingObject.global_rotation_degrees.z = angle
			angle = abs(rotatingObject.global_rotation_degrees.z)
			if angle >= 85:
				var i = 1-clamp(inverse_lerp(85,90,angle),0,1)
				light_color = lerp(dawnColor, dayColor, i)
				light_energy = i
			else:
				light_energy = 1
				var i = angle / 85.0
				light_color = lerp(dayColor, Color.WHITE, i)
				light_color = dayColor
			var ambColCfg = Global.Db.ambientLightDayConfiguration as Gradient
			var ambCol = ambColCfg.sample(pp)
			environment.environment.ambient_light_color = ambCol
		else:
			rotatingObject.global_rotation_degrees.y = -p+angleOffset

