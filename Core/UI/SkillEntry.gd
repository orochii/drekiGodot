extends Button
class_name SkillEntry

@export var itemIcon:NinePatchRect
@export var itemName:Label

var skill:UseableSkill

func setup(_skill:UseableSkill):
	skill = _skill
	if(skill==null): return
	itemIcon.texture = skill.icon
	itemName.text = skill.name
	print(skill.name)
