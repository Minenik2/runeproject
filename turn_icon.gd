class_name turnIcon
extends PanelContainer
const FLOATING_DAMAGE_LABEL = preload("res://assets/combat/floating_damage_label.tscn")
const BUFF_ICON = preload("res://assets/abilities/buffs/buffIcon.tscn")

signal icon_pressed(combatant, sender)
var combatant: CharacterStats = null  # Store the combatant in the TurnIcon

# Set the combatant (called from the Party component)
func set_combatant(combatantSet: CharacterStats):
	%nameLabel.text = combatantSet.character_name
	update_health(combatantSet.current_hp, combatantSet.max_hp)
	update_mp(combatantSet.current_mp, combatantSet.max_mp)
	update_lvl(combatantSet.level)
	self.combatant = combatantSet  # Store the combatant for later access
	updateBuffList()

# Update the health label
func update_health(current, maxHP):
	%hpLabel.text = str(current) + "/" + str(maxHP)
	$VBoxContainer/hpBar.max_value = maxHP
	$VBoxContainer/hpBar.value = current

func update_mp(current, maxMP):
	%mpLabel.text = str(current) + "/" + str(maxMP)
	$VBoxContainer/mpBar.max_value = maxMP
	$VBoxContainer/mpBar.value = current

func update_lvl(current):
	%lvlLabel.text = "Lv. " + str(current)

# Function to get the stored combatant
func get_combatant():
	return combatant

func flash_color(color=Color(0.8, 0.8, 0.8, 1.0)):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.05)
	tween.tween_property(self, "modulate", color, 0.15)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.05)

func show_heal(heal_amount, color=Color(0.229, 0.62, 0.366, 1.0)):
	# Spawn healing popup
	var heal_label = FLOATING_DAMAGE_LABEL.instantiate()
	
	heal_label.set_heal(heal_amount, color)

	%nameLabel.add_child(heal_label)

func show_damage(damage_amount):
	# Spawn healing popup
	var heal_label = FLOATING_DAMAGE_LABEL.instantiate()
	heal_label.global_position = self.get_global_position()
	
	heal_label.set_damage(damage_amount)

	# Add to the PopupLayer CanvasLayer instead of current_scene
	var popup_layer = $"../../../../.."
	popup_layer.add_child(heal_label)

func highlight(enable: bool):
	if enable:
		%nameLabel.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
	else:
		%nameLabel.add_theme_color_override("font_color", Color(1, 1, 1)) # White


func _on_name_label_pressed() -> void:
	emit_signal("icon_pressed", combatant, self)

func updateBuffList():
	var children = %buffList.get_children()
	for c in children:
		c.queue_free()
	for buff in combatant.stat_buffs:
		var buffTexture = BUFF_ICON.instantiate()
		buffTexture.tooltip_strings.append(buff.tooltip())
		%buffList.add_child(buffTexture)


func _on_hp_bar_mouse_entered() -> void:
	%hpLabel.text = "HP: " + str(combatant.current_hp) + "/" + str(combatant.max_hp)

func _on_hp_bar_mouse_exited() -> void:
	%hpLabel.text = str(combatant.current_hp) + "/" + str(combatant.max_hp)

func _on_mp_bar_mouse_entered() -> void:
	%mpLabel.text = "MP: " + str(combatant.current_mp) + "/" + str(combatant.max_mp)

func _on_mp_bar_mouse_exited() -> void:
	%mpLabel.text = str(combatant.current_mp) + "/" + str(combatant.max_mp)
