extends Control

@export var animPlayer:AnimationPlayer
@export var leftSideCenter:Control
@export var nameLabel:Label
@export var levelLabel:Label
@export var lpLabel:Label
@export var mpLabel:Label
@export var descriptionLabel:RichTextLabel
@export var elementsGrid:GridContainer
@export var statesGrid:GridContainer
@export var iconTemplate:PackedScene

var icons = []

func setup(vfx:VisualEffect, user:Node3D, targets:Array):
	#get battlers
	var userBattler:Battler = _getParentBattler(user)
	if userBattler != null: userBattler.battle.ui.visible = false
	var battlers = _getBattler(targets)
	# iterate through
	for b:Battler in battlers:
		#clean
		for i in icons: i.queue_free()
		#refresh
		nameLabel.text = b.battler.getName()
		levelLabel.text = "Lv%d" % b.battler.level
		lpLabel.text = "%d/%d" % [b.battler.currHP, b.battler.getMaxHP()]
		mpLabel.text = "%d/%d" % [b.battler.currMP, b.battler.getMaxMP()]
		var _translatedText = TranslationServer.translate(b.battler.getDesc())
		_translatedText = _translatedText.split("\n")[0]
		descriptionLabel.text = TextUtils.parseText(_translatedText,false)
		#populate grids
		var rates = b.battler.getAffinityRates()
		for j in rates[0]:
			var k = rates[0][j]
			if k[0]==1 && k[1]==1: continue
			var i = iconTemplate.instantiate()
			i.setup(i.elementIcons[j],k)
			elementsGrid.add_child(i)
		for j in rates[1]:
			var k = rates[1][j]
			if k[0]==1 && k[1]==1: continue
			var status:Status = Global.Db.getStatus(j)
			var i = iconTemplate.instantiate()
			i.setup(status.icon,k)
			statesGrid.add_child(i)
		#show
		var _run = true
		animPlayer.play("show")
		await animPlayer.animation_finished
		#wait for input
		while _run:
			if Input.is_action_just_pressed("action_ok"):
				_run = false
			await get_tree().process_frame
		#hide
		animPlayer.play("hide")
		await animPlayer.animation_finished
	#finish
	if userBattler != null: userBattler.battle.ui.visible = true
	vfx.done = true
	vfx.queueForDeletion = true

func _getBattler(targets:Array):
	var ary = []
	for t in targets:
		var p = _getParentBattler(t)
		if p != null: ary.append(p)
	return ary

func _getParentBattler(n:Node):
	if n is Battler:
		return n
	var p = n.get_parent()
	if p != null:
		return _getParentBattler(p)
	return null
