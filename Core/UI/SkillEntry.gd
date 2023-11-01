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
	itemName.text = skill.name

func setEnabled(v:bool):
	self.modulate.a = 1 if v else 0.5
	enabled = v

func _on_pressed():
	skillSelected.emit(self,skill)
