extends Node

func attack(enemy_sprite: enemyIcon, current_ability: Ability, turnOrder: Array[CharacterStats], turn, message_panel, enemiesRes,enemy_container_ui: Array[enemyIcon]):
	var enemy_data = enemy_sprite.get_meta("enemy_data")
		
	# Damage calculation
	var attacker = turnOrder[0]
	var damage = attacker.attack_power
	var defense = enemy_data.defense
	print(attacker.character_name, attacker.critical_chance)
	var is_crit = randf() < attacker.critical_chance
	
	# damage defense calculation
	damage = max(damage * 0.1,damage - defense)
	
	# ability damage implementation
	if current_ability:
		# If it's a damage type ability, apply ability power
		if current_ability.type == 0:  # if the type is damage
			damage = ceil(current_ability.calculate_scaled_power(attacker) + attacker.magic_power)
		attacker.current_mp -= current_ability.mp_cost
	else:
		# Regular attack
		damage = attacker.attack_power
		attacker.restore_mp(3)
	print("attack damage: ", damage, attacker.character_name)
	
	# add variation to damage
	var variation = randf_range(0.8, 1.2)
	damage = damage * variation
	damage = int(damage)  # Optional, if you want whole numbers

	if is_crit:
		$"../crit".play()
		damage = ceil(damage * attacker.critical_multiplier)
	else:
		$"../hit".play()
	
	var message = ""
	
	if current_ability:
		message = "Turn %s: [color=green]%s[/color] casts [color=yellow]%s[/color] on [color=crimson]%s[/color] for [color=red]%d[/color] damage!" % [
				turn, attacker.character_name, current_ability.name,
				enemy_data.character_name, damage
			]
	else:
		message = "Turn %s: [color=green]%s[/color] attacks [color=crimson]%s[/color] for [color=red]%d[/color] damage!" % [
				turn, attacker.character_name,
				enemy_data.character_name, damage
			]
	
	if is_crit:
		message += " [color=yellow](CRITICAL!)[/color]"
	
	message_panel.add_message(message)
	
	# Apply damage
	enemy_data.current_hp -= damage
	print("%s's HP: %d/%d" % [enemy_data.character_name, enemy_data.current_hp, enemy_data.max_hp])
	enemy_sprite.setHP(enemy_data.current_hp)

	# Flash sprite and show damage
	_flash_sprite(enemy_sprite.getTexture())
	if is_crit:
		$"../toastComponent".show_crit_damage_number(damage, enemy_sprite.global_position)
	else:
		$"../toastComponent".show_damage_number(damage, enemy_sprite.global_position)

	# if the target dies
	if enemy_data.current_hp <= 0:
		print(enemy_data.character_name, " is defeated!")
		message_panel.add_message("[color=crimson]%s[/color] is defeated!" % [enemy_data.character_name])
		enemy_container_ui.erase(enemy_sprite)
		enemy_sprite.queue_free()
		enemiesRes.erase(enemy_data)
		turnOrder.erase(enemy_data)
		if !enemy_container_ui.is_empty():
			$"../targetComponent".selectTarget(enemy_container_ui[0])

func _flash_sprite(sprite: TextureRect):
	var tween = create_tween()
	
	# Turn invisible
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.05)
	# Back to visible
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.05)
	# Invisible again
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.05)
	# Final return to normal
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
	tween.tween_callback(Callable(sprite, "_reset_modulate")) # Reset at end
