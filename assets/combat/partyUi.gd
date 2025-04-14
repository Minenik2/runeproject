extends GridContainer 

var turn_order = []
var current_turn_index = 0

# Now takes a single array of combatants
func initialize(combatants: Array):
	# Clear existing children
	for child in get_children():
		child.queue_free()
		
	print(combatants)
	
	# Sort by initiative
	combatants.sort_custom(_sort_by_initiative)
	turn_order = combatants
	update_display()

func _sort_by_initiative(a, b) -> bool:
	return a.calculate_initiative() > b.calculate_initiative()

func update_display():
	# Clear current display
	for child in get_children():
		child.queue_free()
	
	# Add icons for upcoming turns (showing next 5 turns)
	for i in range(current_turn_index, min(current_turn_index + 5, turn_order.size())):
		var combatant = turn_order[i]
		var icon = preload("res://TurnIcon.tscn").instantiate()
		icon.set_combatant(combatant)
		add_child(icon)

func highlight_current_turn():
	if get_child_count() > 0:
		var current_icon = get_child(0)
		# Pulse animation
		var tween = create_tween()
		tween.tween_property(current_icon, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(current_icon, "scale", Vector2(1.0, 1.0), 0.2)

func get_next_combatant():
	if turn_order.is_empty():
		return null
	
	var combatant = turn_order[current_turn_index % turn_order.size()]
	current_turn_index += 1
	update_display()
	return combatant
