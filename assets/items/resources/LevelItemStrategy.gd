class_name LevelItemStrategy
extends BaseItemStrategy

func use(target: CharacterStats, characterIcon: turnIcon) -> Array:
	if target.current_hp <= 0:
		return [false, "Cannot use on the dead."]
	
	characterIcon.show_heal(1, Color(0.412, 0.097, 0.427, 1.0))
	
	target.level_up()
	amount_held -= 1
	
	print(item_name, " used on ", target.character_name)
	return [true]

func effectText():
	return "Increases level by 1 upon use."

func combatText():
	return ", leveling up"
