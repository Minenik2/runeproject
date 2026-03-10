extends Node

# stat upgrades // possibility to construct them here rather than pulling from files
const DEXTERITY_1 = preload("uid://cauwp4r2f6o6r")
const DEXTERITY_12 = preload("uid://cqw2kscsg16l6")
const DEXTERITY_13 = preload("uid://hitu4883ndau")
const FAITH_1 = preload("uid://cmkiksre3kbo")
const FAITH_12 = preload("uid://271mse3cx3ty")
const FAITH_13 = preload("uid://dlps04swhdgej")
const INTRELLIGENCE_1 = preload("uid://xq7teox5y3h0")
const INTRELLIGENCE_12 = preload("uid://4efa55ds0wl3")
const INTRELLIGENCE_13 = preload("uid://bckwspewj6hy0")
const STRENGTH_1 = preload("uid://3qp28xaysxl1")
const STRENGTH_12 = preload("uid://dka0juy0b2bxg")
const STRENGTH_13 = preload("uid://bmr13l5yem1kb")
const VITALITY_1 = preload("uid://r5qywktgemuj")
const VITALITY_12 = preload("uid://cnr6acsjx8uj0")
const VITALITY_13 = preload("uid://2h0w6kdrn37o")

# Pity counters
var rare_pity_counter = 1
var legendary_pity_counter = 1

#drops - stat - amount
var loot_table = {
	"common": [
		DEXTERITY_1,
		FAITH_1,
		INTRELLIGENCE_1,
		STRENGTH_1,
		VITALITY_1
	],
	"rare": [
		DEXTERITY_12,
		FAITH_12,
		INTRELLIGENCE_12,
		STRENGTH_12,
		VITALITY_12
	],
	"legendary": [
		DEXTERITY_13,
		FAITH_13,
		INTRELLIGENCE_13,
		STRENGTH_13,
		VITALITY_13
	]
}

var pull_rates = {
	"legendary": 5,    # 10%
	"rare": 30,   # 30%
	"common": 100    # 60%
}

func roll_upgrade_loot() -> BaseUpgradeStrategy:
	var roll = randf_range(0, 100)
	var rarity = ""
	
	rare_pity_counter += 1
	legendary_pity_counter += 1

	# Determine rarity by cumulative probability ranges
	if roll <= pull_rates["legendary"] or legendary_pity_counter >= 60:
		rarity = "legendary"
		legendary_pity_counter = 0
	elif roll <= pull_rates["rare"] or rare_pity_counter >= 10:
		rarity = "rare"
		rare_pity_counter = 0
	else:
		rarity = "common"
		

	# Shuffle and pick a drop from the chosen pool
	loot_table[rarity].shuffle()
	return loot_table[rarity][0]
