extends PanelContainer

@onready var visual: TextureRect = $VBoxContainer/visualRight
@onready var name_label: Label = $VBoxContainer/nameLabel
@onready var hp_label: Label = $VBoxContainer/HPLabel

var member

func _ready():
	if member:
		set_member(member)

# Assigns a new party member and updates portrait
func set_member(new_member):
	member = new_member  # keep the whole resource
	if visual:
		visual.texture = member.battle_sprite
		name_label.text = member.character_name
		hp_label.text = "HP: %s/%s" % [member.current_hp, member.max_hp]
	else:
		print("Could not find visualRight")
