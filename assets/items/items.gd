extends Resource
class_name Item

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

# Optional: item-specific stats
@export var hp_restore: int = 0
@export var mp_restore: int = 0
@export var increase_level: bool = false

# You can add methods too!
func use(target):
	if hp_restore > 0:
		target.current_hp = min(target.current_hp + hp_restore, target.max_hp)
	if mp_restore > 0:
		target.current_mp = min(target.current_mp + mp_restore, target.max_mp)
	if increase_level:
		target.level_up()
	
	amount_held -= 1
	
	print(item_name, " used on ", target.character_name)
