extends Control

@export var lifetime:float = 2
@export var positionCurve:Curve
@export var opacityCurve:Curve
@export_group("Members")
@export var container:Control
@export var effectivenessTagIn:Label
@export var effectivenessTagOut:Label
@export var effectivenessTagOutBack:Label
@export var damageIn:Label
@export var damageOut:Label
@export var damageOutBack:Label
@export_group("Data files")
@export var effectivenessColors:Array[LabelSettings]
@export var damageColors:Array[LabelSettings]

var lifetimePerc = 0
var battler:Battler

# Display effect- eff(damage,elementCorrection,hit)
func setup(b:Battler,eff:Dictionary):
	battler = b
	# Set damage text
	if eff["hit"]:
		var dmg = eff["damage"] * -1
		var type = "LP"
		if eff.has("type"):
			if eff["type"] == Global.EDamageType.MP: type = "MP"
		if dmg >= 0:
			var damageText = "+%d%s" % [dmg,type]
			_setDamage(damageText, damageColors[1])
		else:
			var damageText = "%d%s" % [dmg,type]
			_setDamage(damageText, damageColors[0])
	else:
		_setDamage("MISS", damageColors[0])
	# Set effectiveness text
	var effectivenessText = ""
	var effectivenessColor = damageColors[2]
	if eff.has("critical"):
		if eff["critical"]: effectivenessText = "CRITICAL"
	if eff.has("elementCorrection"):
		var corr = eff["elementCorrection"]
		if corr < -0.6:
			effectivenessText = "CRITICAL ABSORB"
			effectivenessColor = effectivenessColors[0]
		if corr < 0.0:
			effectivenessText = "ABSORB"
			effectivenessColor = effectivenessColors[1]
		if corr == 0.0:
			effectivenessText = "NULL"
			effectivenessColor = effectivenessColors[2]
		if corr < 1.0:
			effectivenessText = "ABSORB"
			effectivenessColor = effectivenessColors[3]
		if corr > 1.5:
			effectivenessText = "WEAKNESS"
			effectivenessColor = effectivenessColors[4]
		if corr > 2.0:
			effectivenessText = "CRITICAL WEAKNESS"
			effectivenessColor = effectivenessColors[4]
	_setEffectiveness(effectivenessText, effectivenessColor)
	_reposition()

func _process(delta):
	lifetimePerc += delta / lifetime
	# Eventually free yourself
	_reposition()
	if lifetimePerc > 1:
		queue_free()

func _reposition():
	# refresh position
	var pos = battler.battle.posToScreen(battler.global_position)
	pos += Vector2(0, -positionCurve.sample(lifetimePerc))
	self.global_position = pos
	# refresh modulate
	container.modulate.a = opacityCurve.sample(lifetimePerc)

func _setDamage(text, settings:LabelSettings):
	damageIn.add_theme_color_override("font_color", settings.font_color)
	damageIn.text = text
	damageOut.text = text
	damageOutBack.text = text

func _setEffectiveness(text, settings):
	effectivenessTagIn.text = text
	effectivenessTagOut.add_theme_color_override("font_color", settings.font_color)
	effectivenessTagOut.text = text
	effectivenessTagOutBack.text = text
