extends VBoxContainer

func set_combatant(combatant):
	$nameLabel.text = combatant.character_name
	update_health(combatant.current_hp, combatant.max_hp)

func update_health(current, max):
	$hpLabel.text = "HP: " + str(current) +"/"+ str(max)
