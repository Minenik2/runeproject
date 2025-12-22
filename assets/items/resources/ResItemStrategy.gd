class_name ResurrectionItemStrategy
extends BaseItemStrategy

func use(target: CharacterStats, characterIcon: turnIcon) -> Array:
	if target.current_hp > 0:
		return [false, "Target is alive."]
	
	characterIcon.show_heal(1)
	
	target.is_dead = false
	target.current_hp = 1
	amount_held -= 1
	
	print(item_name, " used on ", target.character_name)
	return [true]

func effectText():
	return "Resurrects an ally to 1 HP."
	
func combatText():
	return ", resurrecting them!"
