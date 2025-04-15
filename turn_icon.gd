extends VBoxContainer

var combatant = null  # Store the combatant in the TurnIcon

# Set the combatant (called from the Party component)
func set_combatant(combatant):
	$nameLabel.text = combatant.character_name
	update_health(combatant.current_hp, combatant.max_hp)
	update_mp(combatant.current_mp, combatant.max_mp)
	self.combatant = combatant  # Store the combatant for later access

# Update the health label
func update_health(current, max):
	$hpLabel.text = "HP: " + str(current) + "/" + str(max)

func update_mp(current, max):
	$mpLabel.text = "MP: " + str(current) + "/" + str(max)

# Function to get the stored combatant
func get_combatant():
	return combatant
