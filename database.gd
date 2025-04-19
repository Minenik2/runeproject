extends Node

const BUN = preload("res://assets/characters/heroes/bun.tres")
const MIO = preload("res://assets/characters/heroes/mio.tres")
const FELIPE = preload("res://assets/characters/heroes/felipe.tres")
const LIRAE = preload("res://assets/characters/heroes/lirae.tres")

# healing items
const BLOODLETTING_DRAUGHT = preload("res://assets/items/bloodletting_draught.tres")
const FLESHKNITTER = preload("res://assets/items/fleshknitter.tres")
const MEDICINAL_HERB = preload("res://assets/items/medicinal_herb.tres")

# level icrease unique
const SOUL_HUSK = preload("res://assets/items/soul_husk.tres")

var memberRes: Array[CharacterStats] = [BUN, MIO, FELIPE, LIRAE] # current party member in players party

var enemiesRes: Array[CharacterStats] = [] # current enemy combat enemies
var depth: int = 1
var current_sp = 0

var inventory: Array[Item] = [
	BLOODLETTING_DRAUGHT, 
	FLESHKNITTER, 
	MEDICINAL_HERB, 
	SOUL_HUSK
]

#drops - item - amount
var loot_table = {
	"common": [
		[MEDICINAL_HERB, 2],
		[MEDICINAL_HERB, 1],
		[MEDICINAL_HERB, 3]
	],
	"rare": [
		[MEDICINAL_HERB, 3],
		[BLOODLETTING_DRAUGHT, 1],
		[MEDICINAL_HERB, 4],
		[MEDICINAL_HERB, 5]
	],
	"legendary": [
		[BLOODLETTING_DRAUGHT, 6],
		[FLESHKNITTER, 4],
		[MEDICINAL_HERB, 8],
		[SOUL_HUSK, 1]
	]
}

var pull_rates = {
	"legendary": 0.6,    # 0.6%
	"rare": 5.1,   # 5.1%
	"common": 94.3    # 94.3%
}

func roll_chest_loot():
	var roll = randf_range(0, 100)
	var rarity = ""

	# Determine rarity by cumulative probability ranges
	if roll < pull_rates["legendary"]:
		rarity = "legendary"
	elif roll < pull_rates["legendary"] + pull_rates["rare"]:
		rarity = "rare"
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
		
	
	
