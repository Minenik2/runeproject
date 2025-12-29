extends PanelContainer

@onready var visual: TextureRect = $VBoxContainer/visualRight
@onready var name_label: Label = $VBoxContainer/nameLabel
@onready var hp_label: Label = $VBoxContainer/HPLabel

var member

func _ready():
	if member:
		set_member(member)

# Assigns a new party member and updates portrait
func set_member(new_member: CharacterStats):
	member = new_member  # keep the whole resource
	if visual:
		visual.texture = member.battle_sprite
		name_label.text = member.character_name
		$VBoxContainer/hp_bar.max_value = member.max_hp
		$VBoxContainer/hp_bar.value = member.current_hp
		$VBoxContainer/mp_bar.max_value = member.max_mp
		$VBoxContainer/mp_bar.value = member.current_mp
		
		$VBoxContainer/character_stats/ad.text = "AD:%s" % [member.attack_power]
		$VBoxContainer/character_stats/ap.text = "AP:%s" % [member.magic_power]
		$VBoxContainer/character_stats/def.text = "DEF:%s" % [member.defense]
		$VBoxContainer/character_stats/mdef.text = "MDEF:%s" % [member.magic_defense]
		$VBoxContainer/character_stats/acc.text = "ACC:%s" % [snapped(member.accuracy,0.01)]
		$VBoxContainer/character_stats/eva.text = "EVA:%s" % [snapped(member.evasion,0.01)]
		$VBoxContainer/character_stats/critchance.text = "CRATE:%s" % [snapped(member.critical_chance,0.01)]
		$VBoxContainer/character_stats/critdmg.text = "CDMG:%s" % [snapped(member.critical_multiplier,0.01)]
	else:
		print("Could not find visualRight")
