class_name HealthItemStrategy
extends BaseItemStrategy

@export var hp_restore: int = 0

func use(target: CharacterStats, characterIcon: turnIcon) -> Array:
	if target.current_hp <= 0:
		return [false, "Cannot use on the dead."]
	if target.current_hp == target.max_hp:
		return [false, "Target has max HP"]
	
	characterIcon.show_heal(hp_restore)
	
	target.current_hp = min(target.current_hp + hp_restore, target.max_hp)
	amount_held -= 1
	
	print(item_name, " used on ", target.character_name)
	return [true]

func effectText():
	return "Restores %s health points upon use. " % hp_restore

func combatText():
	return ", restoring [color=lime]%d[/color] HP" % hp_restore
