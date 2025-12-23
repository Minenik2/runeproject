extends Button
class_name ItemIcon

func set_combatant(item: BaseItemStrategy):
	$HBoxContainer2/Name.text = item.item_name
	$nameLabel.text = combatant.character_name
	update_health(combatant.current_hp, combatant.max_hp)
	update_mp(combatant.current_mp, combatant.max_mp)
	update_lvl(combatant.level)
	self.combatant = combatant  # Store the combatant for later access
	updateBuffList()
