extends HBoxContainer

signal party_member_pressed(member)
var party_members = []

func _ready() -> void:
	for c in Database.memberRes:
		c.calculate_derived_stats()
		c.setup_base_stats()
	
	initialize(Database.memberRes)

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
		
		# Connect the signal to a local handler function in CombatScene
		icon.icon_pressed.connect(Callable(self, "_on_party_icon_pressed"))
		
		add_child(icon)

func update_status():
	for i in range(party_members.size()):
		var icon = get_child(i)
		icon.set_combatant(party_members[i])

func _on_party_icon_pressed(member, sender):
	emit_signal("party_member_pressed", member)
