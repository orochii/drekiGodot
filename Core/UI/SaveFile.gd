extends Control

@export var slotName:Label
@export var slotNum:Label
@export var leaderName:Label
@export var leaderLevel:Label
@export var areaName:Label
@export var playTime:Label
@export var saveStamp:Label
@export var partyIcons:Array[NinePatchRect]
@export var animatedIcons:Array[NinePatchRect]
@export var partyBack:NinePatchRect
@export var partyBackTextures:Array[Texture2D]
@export var windowBack:NinePatchRect

var screenshot:Texture2D = null

func setup(slot:String,idx:int):
	# Slot info
	slotName.text = "" #slot
	slotNum.text = "%d" % idx
	# Load screenshot
	screenshot = Global.loadGameScreenshot(slot)
	# Read data
	var data:Dictionary = Global.readGame(slot)
	if(data.has("party")):
		var currParty = 0
		if data["party"].has("currentParty"): currParty = data["party"]["currentParty"]
		var party = data["party"]["members"][currParty]
		var members = []
		for p in party:
			for m in data["actors"]:
				if m["id"]==p:
					members.append(m)
					break
		areaName.text = "" # TODO
		
		playTime.text = Global.State.formatPlayTime(data["playTime"])
		saveStamp.text = data["timestamp"]
		if members.size() != 0:
			leaderName.text = members[0]["name"]
			leaderLevel.text = "%d" % members[0]["level"]
			for i in range(partyIcons.size()):
				if i < members.size():
					var actor = Global.Db.getActor(members[i]["id"])
					if actor != null:
						partyIcons[i].visible = true
						partyIcons[i].texture = actor.faceSmall
					else:
						partyIcons[i].visible = false
				else:
					partyIcons[i].visible = false
			for a in animatedIcons: a.visible=true
			partyBack.texture = partyBackTextures[1]
			windowBack.modulate.a = 1
			return
	#
	leaderName.text = ""
	leaderLevel.text = ""
	for i in partyIcons: i.visible=false
	for a in animatedIcons: a.visible=false
	partyBack.texture = partyBackTextures[0]
	windowBack.modulate.a = 0.5
	areaName.text = "" # TODO
	playTime.text = ""
	saveStamp.text = ""
