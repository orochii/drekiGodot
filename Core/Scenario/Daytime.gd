extends DirectionalLight3D

const DAY_LENGTH : float = 24*3600.0

@export var rotatingObject : Node3D = null
@export var town : bool = true
@export var angleOffset : float = 0
@export var dayColor : Color
@export var dawnColor : Color
@export var environment : WorldEnvironment

@export_group("Sky Backdrop")
@export var skyMesh:MeshInstance3D
@export var skyMatIdx:int
@export var skyMatColorPropertyName:StringName

var _shadermat:ShaderMaterial = null
var _originalMatColor:Color
var _currSkyColor:Color
var _currentDayPerc:float

func _ready():
	refreshAngle()
	if skyMesh != null:
		var _m = skyMesh.get_active_material(skyMatIdx)
		if _m is ShaderMaterial:
			_shadermat = _m.duplicate(true)
			skyMesh.set_surface_override_material(skyMatIdx, _shadermat)
			_originalMatColor = _shadermat.get_shader_parameter(skyMatColorPropertyName)
			_refreshColor()

func _process(delta):
	refreshAngle()

func refreshAngle():
	var t = Global.State.gameTime
	var s = t["s"]+t["m"]*60+t["h"]*3600
	var pp = (s / DAY_LENGTH)
	var p = pp * 360
	_currentDayPerc = pp
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

func _refreshColor():
	if _shadermat != null:
		var skyColCfg = Global.Db.skyColorConfiguration as Gradient
		_currSkyColor = skyColCfg.sample(_currentDayPerc)
		_shadermat.set_shader_parameter(skyMatColorPropertyName,_currSkyColor)