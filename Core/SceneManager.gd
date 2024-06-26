extends Control
class_name SceneManager

const TRANSFER_FADE_LEN = 0.5
signal onFadeEnd()
signal onTransitionEnd()
signal onBattleEnd()
signal onSubsceneEnd()

@export var cover : TextureRect
@export var transition : TextureRect
@export var breakScreen : BreakScreen_Transition
@export var transitionPlayer : AnimationPlayer
@export var battleSceneTemplate : PackedScene
@export var shopSceneTemplate : PackedScene
@export var bankSceneTemplate : PackedScene
@export var loadingOverlay : Control

var transferring = false
var originalTexture : Texture
var fadeState = 1
var fadeTarget = 0
var fadeDuration = 1
var currentScene : Node = null
var pausingEntities = []
var transitioning = false
var battleInstance:BattleManager = null
var battleResult:BattleManager.EBattleResult

func _ready():
	cover.visible = true
	originalTexture = cover.texture

func _process(delta):
	# Fade
	if fadeDuration>0:
		fadeState = move_toward(fadeState, fadeTarget, delta/fadeDuration)
		cover.modulate.a = fadeState
		if fadeState == fadeTarget: 
			fadeDuration = 0
			onFadeEnd.emit()

func transfer(newMap):
	transferring = true
	pausingEntities.clear()
	askPause(self)
	# Fade out
	fadeOut(TRANSFER_FADE_LEN)
	await onFadeEnd
	if newMap != "":
		Global.State.lastSceneName = newMap
		# Clear state signals
		Global.State.clearStateSignals()
		Global.Ev.flush()
		# Unload map
		var scene : Node3D = Global.getSceneRoot()
		scene.get_parent().remove_child(scene)
		scene.queue_free()
		# Load map
		#var newScene = load(newMap)
		await loadingOverlay.load(newMap)
		var newScene = loadingOverlay.loadedRes
		# Instantiate
		var i = newScene.instantiate()
		get_tree().root.add_child(i)
		currentScene = i
	# Update characters
	Global.State._deserializeCharacters()
	askUnpause(self)
	await get_tree().create_timer(0.1).timeout
	askPause(self)
	# Fade in
	fadeIn(TRANSFER_FADE_LEN)
	await onFadeEnd
	askUnpause(self)
	transferring = false

func callGameOver():
	Global.Scene.transfer(Global.Scene.sceneFullname("gameover"))

func sceneFullname(s:String):
	return "res://Maps/" + s + ".tscn"

func callShop(items:Array):
	# Set items
	Global.State.shopCurrentItems = items
	await openUI(shopSceneTemplate)

func callBank():
	await openUI(bankSceneTemplate)

func openUI(template:PackedScene):
	# Fade out
	Global.cacheScreenshot()
	Global.Scene.performTransition()
	await get_tree().create_timer(0.05).timeout
	# Create shop as popup
	var inst = template.instantiate()
	Global.UI.subsceneParent.add_child(inst)
	Global.Scene.askPause(inst)
	# Fade in
	#fadeIn(TRANSFER_FADE_LEN)
	#await onFadeEnd
	# Wait for UI to be closed
	await onSubsceneEnd

func closeUI(uiInstanceRoot:Node):
	# Fade out
	Global.Scene.performTransition()
	await get_tree().create_timer(0.05).timeout
	# Destroy
	uiInstanceRoot.queue_free()
	askUnpause(uiInstanceRoot)
	onSubsceneEnd.emit()

func callBattle(troop:EnemyTroop):
	Global.backupRetry()
	breakScreenTransition()
	await get_tree().process_frame
	if Global.Map.battleback != null:
		currentScene.visible = false
	else:
		Global.Map.setForBattle(true)
	Global.State.currentTroop = troop
	battleInstance = battleSceneTemplate.instantiate()
	Global.get_parent().add_child(battleInstance)
	askPause(battleInstance)
	await onBattleEnd

func inBattle():
	return battleInstance != null

func endBattle():
	if(battleInstance == null): return
	fadeOut(TRANSFER_FADE_LEN)
	await onFadeEnd
	battleInstance.queue_free()
	currentScene.visible = true
	Global.Map.setForBattle(false)
	askUnpause(battleInstance)
	battleInstance = null
	fadeIn(TRANSFER_FADE_LEN)
	await onFadeEnd
	onBattleEnd.emit()

func toTitle():
	Global.Audio.fadeOutBGM(0.5)
	pausingEntities.clear()
	Global.Scene.transfer("res://Scenes/title.tscn")

func quit():
	get_viewport().gui_release_focus()
	askPause(self)
	fadeOut(1)
	await onFadeEnd
	get_tree().quit()
	pass

func fadeIn(duration:float):
	fadeState = 1
	fadeTarget = 0
	fadeDuration = duration
func fadeOut(duration:float):
	# var img = get_viewport().get_texture().get_image()
	# var tex = ImageTexture.create_from_image(img)
	# cover.texture = tex
	fadeState = 0
	fadeTarget = 1
	fadeDuration = duration

func askPause(asker):
	if !pausingEntities.has(asker):
		pausingEntities.append(asker)
	if pausingEntities.size() > 0:
		get_tree().paused = true
func askUnpause(asker):
	if pausingEntities.has(asker):
		pausingEntities.erase(asker)
	if pausingEntities.size() <= 0:
		get_tree().paused = false

func performTransition():
	if(transitioning):return
	transitioning = true
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	transition.texture = tex
	var s = transition.material as ShaderMaterial
	s.set_shader_parameter("threshold", 1)
	transition.visible = true
	transitionPlayer.speed_scale = 4
	transitionPlayer.play("execute")
	askPause(self)

func breakScreenTransition():
	if(transitioning):return
	transitioning = true
	var img = get_viewport().get_texture().get_image()
	var tex = ImageTexture.create_from_image(img)
	breakScreen.setTexture(tex)
	transitionPlayer.speed_scale = 1
	transitionPlayer.play("break")
	askPause(self)

func _on_transition_player_animation_finished(anim_name):
	transitioning = false
	onTransitionEnd.emit()
	askUnpause(self)

func goToRespawn():
	Global.State.targetGate = int(Global.State.lastRespawn["gate"])
	Global.Scene.transfer("res://Maps/" + Global.State.lastRespawn["map"] + ".tscn")
