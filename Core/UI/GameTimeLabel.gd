extends Label

@export_multiline var format:String = "%02d:%02d:%02d\n%s %d %s, %d"

# Called when the node enters the scene tree for the first time.
func _ready():
	refreshText()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	refreshText()

func refreshText():
	var t = Global.State.gameTime
	var weekdayName = Global.State.WEEKDAY_NAMES[Global.State.weekday()]
	var monthName = Global.State.MONTH_NAMES[t["month"]].to_upper()
	self.text = format % [t["h"],t["m"],t["s"],weekdayName,t["day"]+1,monthName,t["year"]]
