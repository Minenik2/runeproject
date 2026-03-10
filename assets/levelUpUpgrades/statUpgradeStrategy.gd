extends BaseUpgradeStrategy
class_name statUpgradeStrategy

enum STAT_TYPE {
	STRENGTH,
	INTELLIGENCE,
	VITALITY,
	DEXTERITY,
	FAITH,
}

@export var stat_increase: STAT_TYPE = STAT_TYPE.STRENGTH
@export var upgrade_amount: int = 1

func applyUpgrade(character: CharacterStats):
	match stat_increase:
		STAT_TYPE.STRENGTH:
			character.strength += upgrade_amount
		STAT_TYPE.INTELLIGENCE:
			character.intelligence += upgrade_amount
		STAT_TYPE.VITALITY:
			character.vitality += upgrade_amount
		STAT_TYPE.DEXTERITY:
			character.dexterity += upgrade_amount
		STAT_TYPE.FAITH:
			character.faith += upgrade_amount
	
	character.calculate_derived_stats()

func description() -> String:
	var stat_name = STAT_TYPE.keys()[stat_increase].capitalize()
	return "Increase %s by %d" % [stat_name, upgrade_amount]
