extends Control

@export var screenPositionNode:Control
@export var itemNameLabel:RichTextLabel

func setup(item:BaseItem,amount:int,pos:Vector2):
	screenPositionNode.position = pos
	var iconName = item.icon.resource_path
	var itemName = TranslationServer.translate(item.getName())
	var format = TranslationServer.translate("item_get")
	itemNameLabel.text = format % [iconName,itemName,amount]

func _on_animation_player_animation_finished(anim_name):
	queue_free()
