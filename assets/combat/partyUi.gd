extends GridContainer 

var party_members = []

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
