extends VBoxContainer
const FLOATING_DAMAGE_LABEL = preload("res://assets/combat/floating_damage_label.tscn")

signal icon_pressed(combatant, sender)
var combatant = null  # Store the combatant in the TurnIcon

# Set the combatant (called from the Party component)
func set_combatant(combatant):
	$nameLabel.text = combatant.character_name
	update_health(combatant.current_hp, combatant.max_hp)
	update_mp(combatant.current_mp, combatant.max_mp)
	update_lvl(combatant.level)
	self.combatant = combatant  # Store the combatant for later access

# Update the health label
func update_health(current, max):
	$hpLabel.text = "HP: " + str(current) + "/" + str(max)

func update_mp(current, max):
	$mpLabel.text = "MP: " + str(current) + "/" + str(max)

func update_lvl(current):
	$lvlLabel.text = "Lv. " + str(current)

# Function to get the stored combatant
func get_combatant():
	return combatant

func show_heal(heal_amount):
	# Spawn healing popup
	var heal_label = FLOATING_DAMAGE_LABEL.instantiate()
	
	heal_label.set_heal(heal_amount)

	$nameLabel.add_child(heal_label)

func show_damage(damage_amount):
	# Spawn healing popup
	var heal_label = FLOATING_DAMAGE_LABEL.instantiate()
	heal_label.global_position = self.get_global_position()
	
	heal_label.set_damage(damage_amount)

	# Add to the PopupLayer CanvasLayer instead of current_scene
	var popup_layer = $"../../.."
	popup_layer.add_child(heal_label)

func highlight(enable: bool):
	if enable:
		$nameLabel.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
	else:
		$nameLabel.add_theme_color_override("font_color", Color(1, 1, 1)) # White


func _on_name_label_pressed() -> void:
	emit_signal("icon_pressed", combatant, self)
