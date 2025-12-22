extends BaseSpellStrategy
class_name HealthSpellStrategy

func cast(caster: CharacterStats, reciever: CharacterStats, characterIcon: turnIcon, _enemy_sprite: enemyIcon) -> Array:
	if reciever.is_dead:
		return [false, "[color=green]%s[/color] is dead!" % reciever.character_name]
	
	if reciever.current_hp == reciever.max_hp:
		return [false, "[color=green]%s[/color] is max hp!" % reciever.character_name]
	
	# Calculate heal amount
	var heal_amount = calculate_scaled_power(caster)
	var variation = randf_range(0.8, 1.2)
	heal_amount *= variation
	heal_amount = int(heal_amount)  # If you want whole numbers
	
	characterIcon.show_heal(heal_amount)
	
	caster.current_mp -= mp_cost

	# Clamp healing so it doesn't overheal
	reciever.current_hp = min(reciever.current_hp + heal_amount, reciever.max_hp)
	return [true, ", restoring [color=lime]%d[/color] HP" % heal_amount]
