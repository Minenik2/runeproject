# CombatManager.gd
extends Node

# Node References
@onready var current_member_display = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/currentPlayerInfo"
@onready var action_menu = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu"
@onready var enemy_container = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/enemyGroup"
@onready var party_ui: GridContainer = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/PartyUI"
@onready var message_panel: Panel = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/messagePanel"
@onready var current_player_info: PanelContainer = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/currentPlayerInfo"
@onready var turn_indicator: Label = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/PanelContainer/HBoxContainer/turnIndicator"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var ui: Control = $"../CanvasLayer/UI"

# Combat Variables
var party_members = ["player", "miku", "felipe", "mio"]
var enemies = ["goblin", "goblin"]
var memberRes = []
var enemiesRes = []
var targeting_mode = false
var current_member_index = 0
var turnOrder = []
var turn = 1

# Resource paths
const CHARACTER_PATH = "res://assets/characters/heroes/"
const ENEMY_PATH = "res://assets/characters/enemies/"

func _ready() -> void:
	start_combat()

func start_combat():
	# Load party members
	for member_name in party_members:
		var member = load(CHARACTER_PATH + member_name + ".tres")
		member.is_ally = true
		memberRes.append(member)
		
	# Load enemies
	for enemy_name in enemies:
		var enemy = load(ENEMY_PATH + enemy_name + ".tres").duplicate()
		enemy.is_ally = false
		enemiesRes.append(enemy)
	
	# Add them into the turn order
	calculate_turn_order()

	# Load visuals
	party_ui.initialize(memberRes)
	
	for child in enemy_container.get_children():
		child.queue_free()

	for enemy_data in enemiesRes:
		var enemy_sprite = TextureRect.new()
		enemy_sprite.texture = enemy_data.battle_sprite
		enemy_sprite.set_meta("enemy_data", enemy_data)
		enemy_sprite.connect("gui_input", Callable(self, "_on_enemy_clicked").bind(enemy_sprite))
		enemy_container.add_child(enemy_sprite)

func calculate_turn_order():
	# Combine all combatants
	turnOrder.clear()
	turnOrder.append_array(memberRes)
	turnOrder.append_array(enemiesRes)

	# Roll initiative once and store it
	for c in turnOrder:
		c.combat_initiative = c.calculate_initiative()

	# Sort by stored initiative
	turnOrder.sort_custom(func(a, b):
		return a.combat_initiative > b.combat_initiative)

	# visualise turn order
	current_player_info.set_member(turnOrder[0])

	# Print for debug — now stable and correct
	print("=== Turn Order ===")
	for c in turnOrder:
		print(c.character_name, " (Initiative: ", c.combat_initiative, ")")

func _set_current_member_display(member_name: String):
	current_member_display.clear()  # Remove previous sprite if needed
	var sprite = Sprite2D.new()
	sprite.texture = load(CHARACTER_PATH + member_name + ".png")
	current_member_display.add_child(sprite)

func _on_attack_button_pressed() -> void:
	print("Attack pressed — choose a target")
	message_panel.add_message("Attack pressed — choose a target")
	targeting_mode = true
	_highlight_enemies(true)


func _on_item_button_pressed() -> void:
	print("item!")
	
func _on_enemy_clicked(event: InputEvent, enemy_sprite: TextureRect):
	if targeting_mode and event is InputEventMouseButton and event.pressed:
		$hit.play()
		var enemy_data = enemy_sprite.get_meta("enemy_data")
		
		# Damage calculation
		var attacker = turnOrder[0]
		var damage = attacker.attack_power
		var is_crit = randf() < attacker.critical_chance

		if is_crit:
			damage *= attacker.critical_multiplier

		print("%s attacks %s for %d damage!" % [attacker.character_name, enemy_data.character_name, damage])
		
		# Color formatting
		var attacker_color = "[color=green]" if attacker.is_ally else "[color=crimson]"
		var target_color = "[color=green]" if enemy_data.is_ally else "[color=crimson]"

		var message = "%s%s[/color] attacks %s%s[/color] for [color=red]%d[/color] damage!" % [
			attacker_color, attacker.character_name,
			target_color, enemy_data.character_name,
			damage
		]
		
		if is_crit:
			message += " [color=yellow](CRITICAL!)[/color]"
		
		message_panel.add_message(message)
		
		# Apply damage
		enemy_data.current_hp -= damage
		print("%s's HP: %d/%d" % [enemy_data.character_name, enemy_data.current_hp, enemy_data.max_hp])

		# Flash sprite and show damage
		_flash_sprite(enemy_sprite)
		_show_damage_number(damage, enemy_sprite.global_position, ui)

		if enemy_data.current_hp <= 0:
			print(enemy_data.character_name, " is defeated!")
			message_panel.add_message("[color=crimson]%s[/color] is defeated!" % [enemy_data.character_name])
			enemy_sprite.queue_free()
			enemiesRes.erase(enemy_data)
			turnOrder.erase(enemy_data)
		
		# Move attacker to end of turnOrder
		turnOrder.push_back(turnOrder.pop_front())
		
		# Announce next turn and trigger enemy AI if needed
		_announce_next_turn()

		targeting_mode = false
		_highlight_enemies(false)
		
		# check for combat end
		_check_combat_end()
	
	
func _highlight_enemies(active: bool):
	for enemy in enemy_container.get_children():
		enemy.modulate = Color(1, 0.5, 0.5) if active else Color(1, 1, 1)
		
func _check_combat_end():
	if enemiesRes.is_empty():
		$victory.play()
		print("Combat is over! You win!")
		message_panel.add_message("[color=green]Victory! All enemies defeated![/color]")
		
func _enemy_take_turn():
	var enemy = turnOrder[0]
	
	$enemyHit.play()
	
	# Safety check — skip if no party members
	if memberRes.is_empty():
		print("No party members left — game over")
		message_panel.add_message("[color=crimson]The party has fallen...[/color]")
		return

	# Pick a random party member
	var target_index = randi() % memberRes.size()
	var target = memberRes[target_index]

	# Damage calculation
	var damage = enemy.attack_power
	var is_crit = randf() < enemy.critical_chance

	if is_crit:
		damage *= enemy.critical_multiplier

	print("%s attacks %s for %d damage!" % [enemy.character_name, target.character_name, damage])

	# Color formatting
	var attacker_color = "[color=crimson]"
	var target_color = "[color=green]"

	var message = "%s%s[/color] strikes %s%s[/color] for [color=red]%d[/color] damage!" % [
		attacker_color, enemy.character_name,
		target_color, target.character_name,
		damage
	]
	
	if is_crit:
		message += " [color=yellow](CRITICAL!)[/color]"

	message_panel.add_message(message)

	# Apply damage
	target.current_hp -= damage
	print("%s's HP: %d/%d" % [target.character_name, target.current_hp, target.max_hp])
	
	party_ui.flash_damage(target, damage)
	
	# Trigger screen shake on enemy hit
	shake_screen(10, 0.5)  # Adjust intensity and duration as needed

	# Check if party member died
	if target.current_hp <= 0:
		print(target.character_name, " has fallen!")
		message_panel.add_message("[color=crimson]%s[/color] has fallen!" % target.character_name)
		memberRes.erase(target)
		party_ui.update_party(memberRes)  # Assuming your PartyUI has a way to refresh
	
	party_ui.update_status()

	# Move enemy to end of turnOrder
	turnOrder.push_back(turnOrder.pop_front())

	# Announce next turn
	_announce_next_turn()

func _announce_next_turn():
	turn += 1
	turn_indicator.text = "Turn %s" % turn
	
	if turnOrder[0].is_ally:
		message_panel.add_message("[color=green]%s[/color] takes the initiative." % turnOrder[0].character_name)
	else:
		message_panel.add_message("[color=crimson]%s[/color] takes the initiative." % turnOrder[0].character_name)

	# Update UI
	current_player_info.set_member(turnOrder[0])

	# If it's an enemy, immediately take their turn
	if not turnOrder[0].is_ally:
		_enemy_take_turn()

func _flash_sprite(sprite: TextureRect):
	var tween = create_tween()
	
	# Turn invisible
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.05)
	# Back to visible
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.05)
	# Invisible again
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 0), 0.05)
	# Final return to normal
	tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
	tween.tween_callback(Callable(sprite, "_reset_modulate")) # Reset at end

# Helper function on the enemy sprite to reset modulate
func _reset_modulate():
	return Color(1, 1, 1)
	
func _show_damage_number(amount: int, position: Vector2, parent: Control):
	var label = Label.new()
	label.text = str(amount)
	label.modulate = Color(1, 0.2, 0.2)
	label.add_theme_font_size_override("font_size", 24)
	label.position = position
	parent.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", position.y - 30, 0.6)
	tween.tween_property(label, "modulate:a", 0, 0.6)
	tween.connect("finished", Callable(label, "queue_free"))

# Function to shake the screen (parent or CanvasLayer)
func shake_screen(intensity: float, duration: float):
	var tween = create_tween()
	var initial_position = ui.position  # or canvas_layer.position if that's where you want to shake

	# Set transition and easing method (optional)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	
	# Random shake in x and y directions
	for i in range(5):  # Shake in small bursts
		tween.tween_property(ui, "position", initial_position + Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity)), 0.05)

	# Reset position after shake duration
	tween.tween_property(ui, "position", initial_position, duration)

	# Optionally reset the modulate (if you had any modulate changes before)
	# You could also use a callback to clear anything after the shake
	tween.connect("finished", Callable(self, "_reset_position").bind(initial_position))

# Helper function to reset position if needed (optional)
func _reset_position(initial_position: Vector2):
	ui.position = initial_position
