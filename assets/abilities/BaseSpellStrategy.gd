extends Resource
class_name BaseSpellStrategy

enum TARGETING_TYPE {
	ENEMY,
	ALLY,
	SELFCAST
}

enum TYPE {
	DAMAGE,
	HEAL,
	BUFF,
}

enum SCALING_STAT {
	NONE,
	STRENGTH,
	INTELLIGENCE,
	VITALITY,
	DEXTERITY,
	FAITH,
	SPEED
}

@export var name: String
@export var description: String
@export var type: TYPE = TYPE.DAMAGE
@export var target_type: TARGETING_TYPE = TARGETING_TYPE.ENEMY
@export var power: int
@export var crit_chance: float
@export var mp_cost: int
@export var sp_cost: int
@export var hp_cost: int

@export var scaling_stat: SCALING_STAT = SCALING_STAT.NONE

# New method to calculate final power based on a Character's stats
func calculate_scaled_power(character) -> float:
	var scaling_value = 0.0
	
	match scaling_stat:
		SCALING_STAT.STRENGTH:
			scaling_value = character.strength
		SCALING_STAT.INTELLIGENCE:
			scaling_value = character.intelligence
		SCALING_STAT.VITALITY:
			scaling_value = character.vitality
		SCALING_STAT.DEXTERITY:
			scaling_value = character.dexterity
		SCALING_STAT.FAITH:
			scaling_value = character.faith
		SCALING_STAT.SPEED:
			scaling_value = character.speed
		SCALING_STAT.NONE:
			scaling_value = 0.0
	
	var scaled_power = power + (scaling_value * 0.006)
	return scaled_power

# checks if the ability is possible to be casts
func checkCost(caster: CharacterStats) -> Array:
	if mp_cost > caster.current_mp:
		return [false, "Cannot use ability: %s - not enought mp" % name]
	if sp_cost > Database.current_sp:
		return [false, "Cannot use ability: %s - not enought sp" % name]
	if hp_cost > caster.current_hp:
		return [false, "Cannot use spell: %s - not enought hp" % name]
	return [true]

func cast(caster: CharacterStats, reciever: CharacterStats, characterIcon: turnIcon, enemy_sprite: enemyIcon) -> Array:
	return [false, "This spell does nothing"]

func combatText():
	return "doing nothing"
	
