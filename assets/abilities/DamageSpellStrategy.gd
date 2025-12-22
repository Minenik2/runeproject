extends BaseSpellStrategy
class_name DamageSpellStrategy

func cast(caster: CharacterStats, _reciever: CharacterStats, _characterIcon: turnIcon, enemy_sprite: enemyIcon) -> Array:
	if !enemy_sprite:
		return [false, "BUG: no enemy icon"]
	
	var damageAmount = ceil(calculate_scaled_power(caster) + caster.magic_power)
	caster.current_mp -= mp_cost
	
	return [true, "casted this ability", damageAmount]
