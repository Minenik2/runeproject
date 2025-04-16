# CombatManager.gd
extends Node

# Node References
@onready var current_member_display = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/currentPlayerInfo"
@onready var action_menu = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu"
@onready var enemy_container = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/enemyPanel/enemyGroup"
@onready var party_ui: GridContainer = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/PartyUI"
@onready var message_panel: Panel = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/messagePanel"
@onready var current_player_info: PanelContainer = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/currentPlayerInfo"
@onready var turn_indicator: Label = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/PanelContainer/HBoxContainer/turnIndicator"
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var ui: Control = $"../CanvasLayer/UI"
@onready var description: Label = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/PanelContainer/HBoxContainer/description"

# Combat Variables
var memberRes: Array[CharacterStats] = Database.memberRes
@export var enemiesRes: Array[CharacterStats] = []

var aliveMembers = []
var targeting_mode = false
var ally_targeting_mode = false
var current_member_index = 0
var turnOrder = []
var turn = 1
var current_ability

func _ready() -> void:
	start_combat()
	randomize()

func start_combat():
	for c in memberRes:
		c.is_ally = true
		c.calculate_derived_stats()
		if not c.is_dead:
			aliveMembers.append(c)
	
	enemiesRes = GameManager.enemiesRes
	
	for i in range(enemiesRes.size()):
		enemiesRes[i] = enemiesRes[i]
		enemiesRes[i].is_ally = false
	
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

	# Print for debug — now stable and correct
	print("=== Turn Order ===")
	for c in turnOrder:
		print(c.character_name, " (Initiative: ", c.combat_initiative, ")")

	# Wait one frame so visuals/turn order UI update
	await get_tree().process_frame

	if not turnOrder[0].is_ally:
		_enemy_take_turn()
	else:
		current_player_info.set_member(turnOrder[0])

#
# ACTION BUTTON FUNCTIONS
#

func _on_attack_button_pressed() -> void:
	print("Attack pressed — choose a target")
	message_panel.add_message("Attack pressed — choose a target")
	targeting_mode = true
	_highlight_enemies(true)

func _on_item_button_pressed() -> void:
	print("item!")

func _on_special_button_2_pressed() -> void:
	var current_member = turnOrder[0]
	var abilities = current_member.abilities
	
	# Clear any previous buttons in the special menu (if any)
	var container = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu"

	# Remove all existing buttons
	for child in container.get_children():
		child.queue_free()

	# Create a button for each ability
	for ability in abilities:
		var button = Button.new()
		button.text = ability.name
		
		# Use a lambda function to call _on_ability_button_pressed with the specific ability
		button.pressed.connect(func(): _on_ability_button_pressed(ability))
		
		# Connect the hover signal
		button.mouse_entered.connect(func():
			description.text = ""
			if ability.mp_cost > 0:
				description.text += "Mp cost: %s, " % ability.mp_cost
			if ability.sp_cost > 0:
				description.text += "Sp cost: %s, " % ability.sp_cost
			if ability.hp_cost > 0:
				description.text += "Hp cost: %s, " % ability.hp_cost
			
			description.text += ability.description
		)

		# Connect the mouse_exited to clear or reset the label
		button.mouse_exited.connect(func():
			description.text = ""
		)
		
		# Add the button to the special menu
		$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu".add_child(button)
	
	# Optionally, you can add a "Cancel" button to return to the action menu
	var cancel_button = Button.new()
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(func(): _on_back_button_pressed())
	$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu".add_child(cancel_button)
	
	$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu".hide()
	$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu".show()
	
#
# ATTACKING ENEMIES
#

func _on_enemy_clicked(event: InputEvent, enemy_sprite: TextureRect):
	if targeting_mode and event is InputEventMouseButton and event.pressed:
		var enemy_data = enemy_sprite.get_meta("enemy_data")
		
		# Damage calculation
		var attacker = turnOrder[0]
		var damage = attacker.attack_power
		var defense = enemy_data.defense
		print(attacker.character_name, attacker.critical_chance)
		var is_crit = randf() < attacker.critical_chance
		
		# damage defense calculation
		damage = max(damage * 0.1,damage - defense)
		
		# ability damage implementation
		if current_ability:
			# If it's a damage type ability, apply ability power
			if current_ability.type == 0:  # if the type is damage
				damage = current_ability.calculate_scaled_power(attacker) + attacker.magic_power
			attacker.current_mp -= current_ability.mp_cost
			
			# hide special menu
			$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu".hide()
			$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu".show()
		else:
			# Regular attack
			damage = attacker.attack_power
		print("attack damage: ", damage, attacker.character_name)
		
		# add variation to damage
		var variation = randf_range(0.8, 1.2)
		damage = damage * variation
		damage = int(damage)  # Optional, if you want whole numbers

		if is_crit:
			$crit.play()
			damage *= attacker.critical_multiplier
		else:
			$hit.play()
		
		var message = ""
		
		if current_ability:
			message = "Turn %s: [color=green]%s[/color] casts [color=yellow]%s[/color] on [color=crimson]%s[/color] for [color=red]%d[/color] damage!" % [
					turn, attacker.character_name, current_ability.name,
					enemy_data.character_name, damage
				]
			current_ability = null
		else:
			message = "Turn %s: [color=green]%s[/color] attacks [color=crimson]%s[/color] for [color=red]%d[/color] damage!" % [
					turn, attacker.character_name,
					enemy_data.character_name, damage
				]
		
		if is_crit:
			message += " [color=yellow](CRITICAL!)[/color]"
		
		message_panel.add_message(message)
		
		# Apply damage
		enemy_data.current_hp -= damage
		print("%s's HP: %d/%d" % [enemy_data.character_name, enemy_data.current_hp, enemy_data.max_hp])

		# Flash sprite and show damage
		_flash_sprite(enemy_sprite)
		if is_crit:
			_show_crit_damage_number(damage, enemy_sprite.global_position, ui)
		else:
			_show_damage_number(damage, enemy_sprite.global_position, ui)

		if enemy_data.current_hp <= 0:
			print(enemy_data.character_name, " is defeated!")
			message_panel.add_message("[color=crimson]%s[/color] is defeated!" % [enemy_data.character_name])
			enemy_sprite.queue_free()
			enemiesRes.erase(enemy_data)
			turnOrder.erase(enemy_data)
		
		# update ui important for specail abilities
		party_ui.update_status()
		
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
		GameManager.play_victory()
		for c in memberRes:
			c.gain_exp(GameManager.get_xp_for_enouncter())
			
		print("Combat is over! You win!")
		message_panel.add_message("[color=green]Victory! All enemies defeated![/color]")
		#await get_tree().create_timer(1.5).timeout  # Let the message sit for a bit
		_end_combat()  # This will remove this combat scene from the tree

#
# ENEMY AI
#

func _enemy_take_turn():
	var enemy = turnOrder[0]
	
	

	# Pick a random party member
	var target_index = randi() % aliveMembers.size()
	var target = aliveMembers[target_index]

	# Damage calculation
	var damage = enemy.attack_power
	var is_crit = randf() < enemy.critical_chance

	if is_crit:
		$enemyCrit.play()
		damage *= enemy.critical_multiplier
	else:
		$enemyHit.play()

	print("%s attacks %s for %d damage!" % [enemy.character_name, target.character_name, damage])

	# Color formatting
	var attacker_color = "[color=crimson]"
	var target_color = "[color=green]"

	var message = "Turn %s: %s%s[/color] strikes %s%s[/color] for [color=red]%d[/color] damage!" % [
		turn, attacker_color, enemy.character_name,
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
		target.current_hp = 0
		target.is_dead = true
		print(target.character_name, " has fallen!")
		message_panel.add_message("[color=green]%s[/color] has fallen!" % target.character_name)
		aliveMembers.erase(target)
	
	party_ui.update_status()

	# Move enemy to end of turnOrder
	turnOrder.push_back(turnOrder.pop_front())

	# Announce next turn
	_announce_next_turn()

func _announce_next_turn():
	if aliveMembers.is_empty():
		message_panel.add_message("[color=crimson]The party has fallen...[/color]")
		# TODO MAKE ENDING
		return
	
	if turnOrder[0].is_dead:
		# Move enemy to end of turnOrder
		turnOrder.push_back(turnOrder.pop_front())
	
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

func _show_crit_damage_number(amount: int, position: Vector2, parent: Control):
	var label = Label.new()
	label.text = str(amount) + "!"
	label.modulate = Color(1, 1, 0)  # Yellow for crit
	label.add_theme_font_size_override("font_size", 28)
	label.position = position
	parent.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", position.y - 40, 0.6)
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


func _on_back_button_pressed() -> void:
	targeting_mode = false
	ally_targeting_mode = false
	_highlight_enemies(false)
	
	$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu".hide()
	$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu".show()
	
# Function to handle the ability use when the button is pressed
func _on_ability_button_pressed(ability) -> void:
	# You can now handle the logic for using the ability
	print("Using ability: ", ability.name)
	if ability.mp_cost > turnOrder[0].current_mp:
		$invalid.play()
		message_panel.add_message("Cannot use ability: %s - not enought mp" % ability.name)
		return
	if ability.sp_cost > Database.current_sp:
		$invalid.play()
		message_panel.add_message("Cannot use ability: %s - not enought sp" % ability.name)
		return
	if ability.hp_cost > turnOrder[0].current_hp:
		$invalid.play()
		message_panel.add_message("Cannot use ability: %s - not enought hp" % ability.name)
		return
		
	message_panel.add_message("Using ability: %s - choose a target" % ability.name)
	current_ability = ability  # store the selected ability
	
	if ability.target_type == 0:
		targeting_mode = true
		_highlight_enemies(true)
	elif ability.target_type == 1:
		ally_targeting_mode = true
	
# the player presses the party member icon
func _on_party_ui_party_member_pressed(member: Variant) -> void:
	if ally_targeting_mode:
		var caster = turnOrder[0]
		var ability = current_ability

		# Consume MP
		caster.current_mp -= ability.mp_cost

		# Hide menus
		$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/specialMenu".hide()
		$"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu".show()

		# Calculate heal amount
		var heal_amount = ability.calculate_scaled_power(caster)
		var variation = randf_range(0.8, 1.2)
		heal_amount *= variation
		heal_amount = int(heal_amount)  # If you want whole numbers

		# Clamp healing so it doesn't overheal
		member.current_hp = min(member.current_hp + heal_amount, member.max_hp)

		# Message
		var message = "Turn %s: [color=green]%s[/color] uses [color=yellow]%s[/color] on [color=green]%s[/color], restoring [color=lime]%d[/color] HP!" % [
			turn, caster.character_name, ability.name, member.character_name, heal_amount
		]
		message_panel.add_message(message)

		# Play heal sound effect (if you have one)
		$heal.play()

		# Flash the target icon
		party_ui.flash_heal(member, heal_amount)
		#party_ui.show_spell_cast(caster, member, current_ability)

		# Reset targeting state
		current_ability = null
		ally_targeting_mode = false

		# Update UI
		party_ui.update_status()

		# Move caster to end of turn order
		turnOrder.push_back(turnOrder.pop_front())

		# Announce next turn
		_announce_next_turn()

		# Check for end of combat (optional, in case you have win/lose conditions)
		_check_combat_end()
		
func _end_combat():
	GameManager.combat_ended()
	print("Combat ended — returning to overworld.")
	$"..".queue_free()  # This will remove this combat scene from the tree
