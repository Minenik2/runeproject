extends Resource
class_name BaseMerchantStrategy

@export var merchant_inventory: Array[sellItem]
@export var texture: Texture

@export var legendary_items: Array[BaseItemStrategy]
@export var rare_items: Array[BaseItemStrategy]
@export var common_items: Array[BaseItemStrategy]

@export var legendary_chance: float = 10
@export var rare_chance: float = 30

@export var stock_amounts: Array[int] = [1,3,5]

# Pity counters
var rare_pity_counter = 1
var legendary_pity_counter = 1

#drops - item - amount
var loot_table = {
	"common": common_items,
	"rare": rare_items,
	"legendary": legendary_items
}

var pull_rates = {
	"legendary": legendary_chance,    # 10%
	"rare": rare_chance,   # 30%
	"common": 100    # 60%
}

func roll_loot():
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
	var stockAmount = stock_amounts.pick_random()
	
	var newItem = sellItem.new(drop, stockAmount)
	merchant_inventory.append(newItem)

func generateInventory():
	for i in stock_amounts.pick_random():
		roll_loot()
