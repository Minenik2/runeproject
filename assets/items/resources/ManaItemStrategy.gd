class_name ManaItemStrategy
extends BaseItemStrategy

@export var mp_restore: int = 0

func use(target: CharacterStats, characterIcon: turnIcon) -> Array:
	if target.current_hp <= 0:
		return [false, "Cannot use on the dead."]
	if target.current_mp == target.max_mp:
		return [false, "Target has max MP"]
	
	characterIcon.show_heal(mp_restore, Color(0.169, 0.429, 0.673, 1.0))
	
	target.current_mp = min(target.current_mp + mp_restore, target.max_mp)
	amount_held -= 1
	
	print(item_name, " used on ", target.character_name)
	return [true]

func effectText():
	return "Restores %s mana points upon use. " % mp_restore
	
func combatText():
	return ", restoring [color=blue]%d[/color] MP" % mp_restore
