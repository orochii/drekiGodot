extends Control
class_name SceneManager

const TRANSFER_FADE_LEN = 0.5
signal onFadeEnd()

@export var cover : TextureRect

var transferring = false
var originalTexture : Texture
var fadeState = 1
var fadeTarget = 0
var fadeDuration = 1
var currentScene : Node = null
var pausingEntities = []

func _ready():
	originalTexture = cover.texture

func _process(delta):
	if fadeDuration>0:
		fadeState = move_toward(fadeState, fadeTarget, delta/fadeDuration)
		cover.modulate.a = fadeState
		if fadeState == fadeTarget: 
			fadeDuration = 0
			onFadeEnd.emit()

func transfer(newMap):
	transferring = true
	askPause(self)
	# Fade out
	fadeOut(TRANSFER_FADE_LEN)
	await onFadeEnd
	if newMap != "":
		# Unload map
		var scene : Node3D = Global.getSceneRoot()
		scene.get_parent().remove_child(scene)
		scene.queue_free()
		# Load map
		var newScene = load(newMap)
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

func fadeIn(duration:float):
	fadeState = 1
	fadeTarget = 0
	fadeDuration = duration
func fadeOut(duration:float):
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
