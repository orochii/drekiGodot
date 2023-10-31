@tool
extends Node2D

@export var battleManager:BattleManager
@export var drawOffset:Vector2 = Vector2(100,100)
@export var drawExtends:Vector2 = Vector2(10,10)
@export var drawScale:float = 10

var indicators:Array = []

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func _draw():
	if Engine.is_editor_hint():
		var offset = drawOffset * drawScale
		if(battleManager==null): return
		if(battleManager.testTroop==null): return
		
		var tl = offset + Vector2(-drawExtends.x,-drawExtends.y) * drawScale
		var tr = offset + Vector2( drawExtends.x,-drawExtends.y) * drawScale
		var bl = offset + Vector2(-drawExtends.x, drawExtends.y) * drawScale
		var br = offset + Vector2( drawExtends.x, drawExtends.y) * drawScale
		draw_line(tl, tr, Color.GREEN, drawScale)
		draw_line(tl, bl, Color.GREEN, drawScale)
		draw_line(tr, br, Color.GREEN, drawScale)
		draw_line(bl, br, Color.GREEN, drawScale)
		# Draw enemy
		for entry in battleManager.testTroop.entries:
			var enemyPos = entry.position
			var pos = offset + Vector2(enemyPos.x, enemyPos.z) * drawScale
			draw_line(pos, pos+Vector2(0,-drawScale), Color.PALE_VIOLET_RED, drawScale)
		# Draw actors area or something?
		for i in range(3):
			var actorPos = battleManager.partyPositionBase + (battleManager.partyPositionOffset * (i-1))
			var pos = offset + Vector2(actorPos.x, actorPos.z) * drawScale
			draw_line(pos, pos+Vector2(0,-drawScale), Color.ALICE_BLUE, drawScale)
