class_name BaseItemStrategy
extends Resource


enum ITEM_TYPE {
	Consumable, # consumable for allies
	throwing # can be thrown at enemies
}

# Declare your item properties
@export var item_name: String = ""
@export var description: String = ""
@export var icon: Texture
@export var item_type = ITEM_TYPE.Consumable
@export var value: int = 0
@export var amount_held: int = 0

func use(target: CharacterStats, characterIcon: turnIcon) -> Array:
	return [false, "This item does nothing"]
	

func effectText():
	return "Basic item"
