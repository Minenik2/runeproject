extends GridContainer 

var party_members = []

# Initialize party UI with party members
func initialize(party_members_array: Array):
	# Store party members locally
	party_members = party_members_array
	
	# Clear existing icons
	for child in get_children():
		child.queue_free()
		
	# Add icons for each party member
	for member in party_members:
		var icon = preload("res://TurnIcon.tscn").instantiate()
		icon.set_combatant(member)
		add_child(icon)

# Update status (like HP bars, status effects, etc)
func update_status():
	for i in range(party_members.size()):
		var icon = get_child(i)
		icon.set_combatant(party_members[i])
