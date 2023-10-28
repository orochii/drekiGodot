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
		
		for entry in battleManager.testTroop.entries:
			var enemyPos = entry.position
			var pos = offset + Vector2(entry.position.x, entry.position.z) * drawScale
			draw_line(pos, pos+Vector2(0,-drawScale), Color.GREEN, drawScale)
