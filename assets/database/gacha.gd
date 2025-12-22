extends Node

# healing items
#const BLOODLETTING_DRAUGHT = Database.BLOODLETTING_DRAUGHT
const FLESHKNITTER = Database.FLESHKNITTER
const MEDICINAL_HERB = Database.MEDICINAL_HERB

# mp restore items
const LITANY_PHIAL = Database.LITANY_PHIAL

# level icrease unique
const SOUL_HUSK = Database.SOUL_HUSK

# Pity counters
var rare_pity_counter = 1
var legendary_pity_counter = 1

#drops - item - amount
var loot_table = {
	"common": [
		[MEDICINAL_HERB, 2],
		[LITANY_PHIAL, 1],
		[MEDICINAL_HERB, 3]
	],
	"rare": [
		[MEDICINAL_HERB, 3],
		[FLESHKNITTER, 1],
		[MEDICINAL_HERB, 4],
		[MEDICINAL_HERB, 5]
	],
	"legendary": [
		[MEDICINAL_HERB, 8],
		[SOUL_HUSK, 1]
	]
}

var pull_rates = {
	"legendary": 10,    # 10%
	"rare": 30,   # 30%
	"common": 100    # 60%
}

func roll_chest_loot():
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
	var drop = loot_table[rarity][0]
	var item = drop[0]
	var quantity = drop[1]

	# Increase item's held amount
	item.amount_held += quantity

	var message = "%s DROP: You found %d x %s!" % [rarity.to_upper(), quantity, item.item_name]
	print(message)
	
	return {
		"text": message,
		"rarity": rarity
	}
