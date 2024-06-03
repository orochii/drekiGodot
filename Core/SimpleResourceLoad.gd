extends Control

@export var characters:Array[Control]

var loadedRes = null

func secureGetParty():
	if Global.State == null || Global.State.party == null: 
		return []
	return Global.State.party.getMembers()

func setCharacters():
	var p = secureGetParty()
	for i in characters.size():
		if i < p.size(): # <>
			var actor:GameActor = Global.State.getActor(p[i])
			characters[i].setup(actor.getGraphic())
		else:
			characters[i].setup(null)

func load(path):
	# Set characters
	setCharacters()
	# Show loading
	visible = true
	# Load resource
	loadedRes = null
	ResourceLoader.load_threaded_request(path)
	var _loading = true
	while _loading:
		var _progress = []
		var _status = ResourceLoader.load_threaded_get_status(path,_progress)
		match _status:
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE,ResourceLoader.THREAD_LOAD_FAILED:
				_loading = false
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				await get_tree().process_frame
			ResourceLoader.THREAD_LOAD_LOADED:
				loadedRes = ResourceLoader.load_threaded_get(path)
				_loading = false
	# Hide loading
	visible = false
