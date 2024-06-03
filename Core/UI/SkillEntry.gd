extends Button
class_name SkillEntry

signal skillSelected(skillEntry:SkillEntry,skill:UseableSkill)

@export var itemIcon:NinePatchRect
@export var itemName:Label

var skill:UseableSkill
var enabled = true

func setup(_skill:UseableSkill):
	skill = _skill
	if(skill==null): return
	itemIcon.texture = skill.icon
	itemName.text = skill.getName()

func setEnabled(v:bool):
	if v: 
		modulate = Global.Db.systemColors[&"enabled"]
	else: 
		modulate = Global.Db.systemColors[&"disabled"]
	enabled = v

func _on_pressed():
	skillSelected.emit(self,skill)
