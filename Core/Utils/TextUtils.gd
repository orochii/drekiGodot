class_name TextUtils

static func parseText(t : String, autotranslate:bool=true):
	if autotranslate:
		t = TranslationServer.translate(t)
	var regex = RegEx.new()
	regex.compile("\\\\BB\\[(.+?)\\]")
	
	var results = regex.search_all(t)
	for r in results:
		var pattern = r.get_string(0)
		var actionName = Global.Db.iconLibrary.getActionIconName(r.get_string(1))
		var name = "[img]" + actionName + "[/img]"
		t = t.replace(pattern, name)
	
	regex.compile("\\\\D\\[(.+)\\]")
	results = regex.search_all(t)
	for r in results:
		var pattern = r.get_string(0)
		var actor : Actor = Global.Db.getActor(r.get_string(1))
		var name = actor.getDesc()
		t = t.replace(pattern, name)
	
	regex.compile("\\\\N\\[(.+)\\]")
	results = regex.search_all(t)
	for r in results:
		var pattern = r.get_string(0)
		var actor : GameActor = Global.State.getActor(r.get_string(1))
		if actor != null:
			var name = actor.getName()
			t = t.replace(pattern, name)
	return t
