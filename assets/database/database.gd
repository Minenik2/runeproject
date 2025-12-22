extends Node

const BUN = preload("res://assets/characters/heroes/bun.tres")
const MIO = preload("res://assets/characters/heroes/mio.tres")
const FELIPE = preload("res://assets/characters/heroes/felipe.tres")
const LIRAE = preload("res://assets/characters/heroes/lirae.tres")

# healing items
#const BLOODLETTING_DRAUGHT = preload("res://assets/items/item_hp_03.tres")
const MEDICINAL_HERB = preload("res://assets/items/item_hp_01.tres")
const FLESHKNITTER = preload("res://assets/items/item_res_01.tres")

# level icrease unique
const SOUL_HUSK = preload("res://assets/items/item_xp_01.tres")

# MP restore items
const LITANY_PHIAL = preload("uid://em12b0k0nyi5")

var memberRes: Array[CharacterStats] = [BUN, MIO, FELIPE, LIRAE] # current party member in players party

var enemiesRes: Array[CharacterStats] = [] # current enemy combat enemies
var depth: int = 1
var current_sp = 0

# labyrinth
var labWidth = 10
var labHeight = 10
var enemiesCounter = 3
var chestCounter = 2

# game manager
var enemyStrength = 5
var giveXP = 25 # amount xp a mob gives

var inventory: Array[BaseItemStrategy] = [ 
	FLESHKNITTER, 
	MEDICINAL_HERB, 
	SOUL_HUSK,
	LITANY_PHIAL
]

		
func reset_game():
	# Reset game variables
	depth = 1
	current_sp = 0
	# labyrinth
	labWidth = 10
	labHeight = 10
	enemiesCounter = 3
	chestCounter = 2
	# game msnager
	enemyStrength = 5

	# Reset inventory quantities
	for item in inventory:
		item.amount_held = 0

	# Reset party members' stats (assuming CharacterStats has HP and status)
	for member in memberRes:
		member.reset_stats()

	# Clear enemies
	enemiesRes.clear()
	
