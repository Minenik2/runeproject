extends GridContainer 

signal party_member_pressed(member)
signal party_member_item_heal_completed(target, item)
var party_members = []
var targetSelectable = false

var selectedItem

# Initialize party UI with party members
func initialize(party_members_array: Array):
	# Store party members locally
	party_members = party_members_array
	
	# Clear existing icons
	for child in get_children():
		child.queue_free()
		
	# Add icons for each party member
	for member in party_members:
		var icon = preload("res://TurnIcon.tscn").instantiate()
		icon.set_combatant(member)
		
		# Connect the signal to a local handler function in CombatScene
		icon.icon_pressed.connect(Callable(self, "_on_party_icon_pressed"))
		
		add_child(icon)
		
func update_status():
	for i in range(party_members.size()):
		var icon = get_child(i)
		icon.set_combatant(party_members[i])
		
# Flash and show damage number for a specific party member
func flash_damage(member, damage):
	for i in range(party_members.size()):
		if party_members[i] == member:
			var icon = get_child(i)
			# Flash effect
			var tween = create_tween()
			tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.05)
			tween.tween_property(icon, "modulate", Color(1, 0.5, 0.5, 1), 0.15)
			tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.05)

			# Damage number (added to external layer)
			if $"..":
				var damage_label = preload("res://assets/combat/floating_damage_label.tscn").instantiate()
				damage_label.set_damage(damage)
				damage_label.z_index = 10
				$"..".add_child(damage_label)
				
				# Position over the icon's global position
				var global_pos = icon.get_global_position()
				damage_label.position = global_pos + Vector2(icon.size.x / 2 - 10, -20)

				# Animate damage number rising + fading
				var dmg_tween = create_tween()
				dmg_tween.tween_property(damage_label, "position:y", damage_label.position.y - 20, 0.5)
				dmg_tween.tween_property(damage_label, "modulate:a", 0, 0.5)
				dmg_tween.tween_callback(Callable(damage_label, "queue_free"))

			break

func flash_heal(member, heal_amount):
	for i in range(party_members.size()):
		if party_members[i] == member:
			var icon = get_child(i)

			# Flash heal effect
			var tween = create_tween()
			tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.05)
			tween.tween_property(icon, "modulate", Color(0.5, 1, 0.5, 1), 0.15)
			tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.05)

			# Floating heal number
			if $"..":
				var heal_label = Label.new()
				heal_label.text = "+%d" % heal_amount
				heal_label.modulate = Color(0.5, 1, 0.5, 1)  # green
				heal_label.z_index = 10
				heal_label.add_theme_color_override("font_color", Color(0.5, 1, 0.5, 1))
				heal_label.set("theme_override/font_sizes/font_size", 22)
				heal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
				heal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

				$"..".add_child(heal_label)

				var global_pos = icon.get_global_position()
				heal_label.position = global_pos + Vector2(icon.size.x / 2 - 10, -20)

				var heal_tween = create_tween()
				heal_tween.tween_property(heal_label, "position:y", heal_label.position.y - 20, 0.5)
				heal_tween.tween_property(heal_label, "modulate:a", 0, 0.5)
				heal_tween.tween_callback(Callable(heal_label, "queue_free"))

			break


# Show spell cast effect from caster to target with the spell name
func show_spell_cast(caster, target, spell):
	for i in range(party_members.size()):
		var icon = get_child(i)
		var member = party_members[i]

		# Highlight caster briefly
		if member == caster:
			var caster_tween = create_tween()
			caster_tween.tween_property(icon, "modulate", Color(0.5, 0.5, 1, 1), 0.1)
			caster_tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.1)

		# If targeting a party member, show a glow on target
		if member == target:
			var target_tween = create_tween()
			target_tween.tween_property(icon, "modulate", Color(0.5, 1, 0.5, 1), 0.1)
			target_tween.tween_property(icon, "modulate", Color(1, 1, 1, 1), 0.1)

			# Floating label for the spell name
			if $"..":
				var spell_label = Label.new()
				spell_label.text = spell.name
				spell_label.z_index = 10
				spell_label.modulate = Color(1, 1, 0.5, 1)
				spell_label.add_theme_font_size_override("font_size", 18)
				$"..".add_child(spell_label)

				# Position over the target icon
				var global_pos = icon.get_global_position()
				spell_label.position = global_pos + Vector2(icon.size.x / 2 - 20, -40)

				# Animate spell label rising and fading
				var spell_tween = create_tween()
				spell_tween.tween_property(spell_label, "position:y", spell_label.position.y - 20, 0.7)
				spell_tween.tween_property(spell_label, "modulate:a", 0, 0.7)
				spell_tween.tween_callback(Callable(spell_label, "queue_free"))

func _on_party_icon_pressed(member, sender):
	print("You clicked on: ", member.character_name, sender)
	emit_signal("party_member_pressed", member)
	# Here you could also check if targeting_mode is active, for healing, buffs, etc.
	if targetSelectable and selectedItem:
		var item = selectedItem
	
		# Check if this item restores HP or MP, and if the target is already at max for both
		var restores_hp = item.hp_restore > 0
		var restores_mp = item.mp_restore > 0
		var hp_full = member.current_hp == member.max_hp
		var mp_full = member.current_mp == member.max_mp
		
		# Block if trying to heal a dead person
		if member.is_dead and (restores_hp or restores_mp or item.increase_level):
			$"../../../../../../CombatManager/invalid".play()
			$"../PanelContainer/HBoxContainer/description".text = "Cannot use on the dead"
			return
				
		# If the item restores either HP or MP, and both are already full, block it
		if (restores_hp or restores_mp) and ((restores_hp and hp_full) and (restores_mp and mp_full)):
			$"../../../../../../CombatManager/invalid".play()
			$"../PanelContainer/HBoxContainer/description".text = "Target has max HP and MP"
			return
		elif restores_hp and hp_full and not restores_mp:
			$"../../../../../../CombatManager/invalid".play()
			$"../PanelContainer/HBoxContainer/description".text = "Target has max HP"
			return
		elif restores_mp and mp_full and not restores_hp:
			$"../../../../../../CombatManager/invalid".play()
			$"../PanelContainer/HBoxContainer/description".text = "Target has max MP"
			return
		
		# Apply item effects
		if restores_hp:
			sender.show_heal(item.hp_restore)
		if restores_mp:
			sender.show_heal(item.mp_restore) # TODO: color this blue
		if item.increase_level:
			sender.show_heal(1) # TODO: color this purple
		
		$"../../../../../../CombatManager/heal".play()
		# send to combat manager for updating turn order
		emit_signal("party_member_item_heal_completed", member, selectedItem)
		
		selectedItem.use(member)
		if selectedItem.amount_held < 1:
			selectedItem = null
			targetSelectable = false
			clear_highlights()
	
		update_status()
		$"../itemMenu/inventoryUI".update_inventory()
		

func highlight_all():
	for icon in get_children():
		icon.highlight(true)

func clear_highlights():
	for icon in get_children():
		icon.highlight(false)


func _on_inventory_ui_item_pressed(item: Variant) -> void:
	if item.item_type == 0:
		Music.play_ui_hit_combat()
		highlight_all()
		targetSelectable = true
		selectedItem = item


func _on_back_button_pressed() -> void:
	selectedItem = null
	targetSelectable = false
	clear_highlights()
