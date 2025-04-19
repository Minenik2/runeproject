extends GridContainer

signal party_member_pressed(member, sender)
signal sendt_message(message) # this signal is to send a message that can be either placed on a tooltip, or combat log
var party_members = []
var targetSelectable = false

var selectedItem

func _ready() -> void:
	for c in Database.memberRes:
		c.calculate_derived_stats()
	
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
	emit_signal("party_member_pressed", member, sender)

func _on_inventory_ui_item_pressed(item: Variant) -> void:
	Music.play_ui_hit()
	if targetSelectable and selectedItem == item:
		targetSelectable = false
		selectedItem = null
		
		emit_signal("sendt_message", "Select an item")
		
		clear_highlights()
	else:
		targetSelectable = true
		selectedItem = item
		
		var message = "Currently selected: %s - Chose target" % item.item_name
		emit_signal("sendt_message", message)
		
		highlight_all()

func highlight_all():
	for icon in get_children():
		icon.highlight(true)

func clear_highlights():
	for icon in get_children():
		icon.highlight(false)
