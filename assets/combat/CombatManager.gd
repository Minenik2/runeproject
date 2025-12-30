# CombatManager.gd
extends Node

# Node References
@onready var action_menu = %actionMenu
@onready var item_menu: VBoxContainer = %itemMenu
@onready var special_menu: VBoxContainer = %specialMenu
@onready var enemy_container = %enemyGroup
@onready var party_ui: combatPartyShowcaseUI = %PartyUI
@onready var message_panel: Panel = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/messagePanel"
@onready var current_player_info: PanelContainer = %currentPlayerInfo
@onready var turn_indicator: Label = %turnIndicator
@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var ui: Control = $"../CanvasLayer/UI"
@onready var description: Label = %description

const NORMAL_COMBAT = preload("uid://dfp3v14drfldu")
const HOVER_COMBAT = preload("uid://dku3i7kc8lhey")
const PRESSED_COMBAT = preload("uid://dw1ecoumkr2uh")





@onready var target_component: Node = $targetComponent

# ui
var enemy_container_ui: Array[enemyIcon]

# Combat Variables
var memberRes: Array[CharacterStats] = Database.memberRes
@export var enemiesRes: Array[CharacterStats] = []

var aliveMembers = []
var targeting_mode = false
var ally_targeting_mode = false
var current_member_index = 0
var turnOrder: Array[CharacterStats] = []
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

	var firstTarget = true

	for enemy_data in enemiesRes:
		var enemy_sprite = load("res://assets/combat/enemies/enemyIcon.tscn").instantiate()
		enemy_sprite.setTexture(enemy_data.battle_sprite)
		enemy_sprite.setMaxHP(enemy_data.max_hp)
		enemy_sprite.setHP(enemy_data.current_hp)
		enemy_sprite.set_meta("enemy_data", enemy_data)
		enemy_container_ui.append(enemy_sprite)
		enemy_sprite.connect("gui_input", Callable(target_component, "_on_enemy_clicked").bind(enemy_sprite))
		target_component.connect("newtarget", Callable(enemy_sprite, "hideTarget"))
		enemy_container.add_child(enemy_sprite)
	
		if firstTarget:
			target_component.currentTarget = enemy_sprite
			enemy_sprite.showTarget()
			firstTarget = false

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
	
	while turnOrder[0].is_dead:
		# Move dead ally to end of turnOrder
		turnOrder.push_back(turnOrder.pop_front())

	if not turnOrder[0].is_ally:
		_enemy_take_turn()
	else:
		current_player_info.set_member(turnOrder[0])

#
# ACTION BUTTON FUNCTIONS
#

func _on_attack_button_pressed() -> void:
	#Music.play_ui_hit_combat()
	$playerAttackComponent.attack($targetComponent.currentTarget,current_ability,turnOrder,turn,message_panel,enemiesRes,enemy_container_ui)
	postAttack()

# logic to run after an attack has been made
func postAttack():
	# update ui important for specail abilities
	party_ui.update_status()
	
	# Move attacker to end of turnOrder
	turnOrder.push_back(turnOrder.pop_front())
	
	# Announce next turn and trigger enemy AI if needed
	_announce_next_turn()
	
	# check for combat end
	_check_combat_end()

func _on_item_button_pressed() -> void:
	Music.play_ui_hit_combat()
	targeting_mode = false
	ally_targeting_mode = false
	_highlight_enemies(false)
	party_ui.clear_highlights()
	action_menu.hide()
	item_menu.show()

func _on_special_button_2_pressed() -> void:
	Music.play_ui_hit_combat()
	var current_member = turnOrder[0]
	var abilities = current_member.abilities
	
	targeting_mode = false
	ally_targeting_mode = false
	_highlight_enemies(false)
	party_ui.clear_highlights()
	
	# Clear any previous buttons in the special menu (if any)
	var container = %specialMenu

	# Remove all existing buttons
	for child in container.get_children():
		child.queue_free()

	# Create a button for each ability
	for ability in abilities:
		var button = Button.new()
		button.add_theme_stylebox_override("normal",NORMAL_COMBAT)
		button.add_theme_stylebox_override("hover", HOVER_COMBAT)
		button.add_theme_stylebox_override("pressed", PRESSED_COMBAT)
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
		special_menu.add_child(button)
	
	# Optionally, you can add a "Cancel" button to return to the action menu
	var cancel_button = Button.new()
	cancel_button.add_theme_stylebox_override("normal",NORMAL_COMBAT)
	cancel_button.add_theme_stylebox_override("hover", HOVER_COMBAT)
	cancel_button.add_theme_stylebox_override("pressed", PRESSED_COMBAT)
	cancel_button.add_theme_font_size_override("font", 22)
	cancel_button.text = "Cancel"
	cancel_button.pressed.connect(func(): _on_back_button_pressed())
	special_menu.add_child(cancel_button)
	
	action_menu.hide()
	special_menu.show()
	
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
		GameManager.combat_ended()
		_end_combat()  # This will remove this combat scene from the tree
	
	if aliveMembers.is_empty():
		message_panel.add_message("[color=crimson]The party has fallen...[/color]")
		
		var fade_overlay = $"../CanvasLayer/UI/defeatFade"
		# Show and fade in the overlay
		fade_overlay.visible = true
		fade_overlay.modulate.a = 0.0  # Start transparent
		
		%"actionMenu/attackButton".disabled = true
		%"actionMenu/specialButton".disabled = true
		%"actionMenu/itemButton".disabled = true

		var tween = create_tween()
		tween.tween_property(fade_overlay, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

		Database.reset_game()
		GameManager.combat_ended()

		# After fade, restart the scene
		tween.tween_callback(func():
			GameManager.generate_new_maze()
			_end_combat()
			%"actionMenu/attackButton".disabled = false
			%"actionMenu/specialButton".disabled = false
			%"actionMenu/itemButton".disabled = false
		)

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
		Music.play_death()
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
	# if the party is dead return the _check_combat_end function will end the combat
	if aliveMembers.is_empty():
		return
	
	while turnOrder[0].is_dead:
		# Move dead ally to end of turnOrder
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

# Helper function on the enemy sprite to reset modulate
func _reset_modulate():
	return Color(1, 1, 1)
	

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
	Music.play_ui_hit_combat()
	ally_targeting_mode = false
	party_ui.clear_highlights()
	
	special_menu.hide()
	item_menu.hide()
	action_menu.show()
	
# Function to handle the ability use when the button is pressed
func _on_ability_button_pressed(ability: BaseSpellStrategy) -> void:
	Music.play_ui_hit_combat()
	
	# You can now handle the logic for using the ability
	print("Using spell: ", ability.name)
	var check = ability.checkCost(turnOrder[0])
	if !check[0]:
		$invalid.play()
		message_panel.add_message(check[1])
		return
		
	message_panel.add_message("Using spell: %s" % ability.name)
	
	if ability.target_type == BaseSpellStrategy.TARGETING_TYPE.ENEMY:
		$playerAttackComponent.attack($targetComponent.currentTarget,ability,turnOrder,turn,message_panel,enemiesRes,enemy_container_ui)
		current_ability = null
		# hide special menu
		special_menu.hide()
		action_menu.show()
		postAttack()
	elif ability.target_type == BaseSpellStrategy.TARGETING_TYPE.ALLY:
		ally_targeting_mode = true
		current_ability = ability
		party_ui.highlight_all()
	elif ability.target_type == BaseSpellStrategy.TARGETING_TYPE.SELFCAST:
		var castSpell = ability.cast(turnOrder[0], turnOrder[0], null, null)
		if !castSpell[0]:
			$invalid.play()
			message_panel.add_message(castSpell[1])
			return
		var message = "Turn %s: [color=green]%s[/color] uses [color=yellow]%s[/color] on herself" % [
			turn, turnOrder[0].character_name, ability.name
		]
		message += ability.combatText()
		message_panel.add_message(message)
		$heal.play()
		party_ui.updateAllBuff()
		current_ability = null
		# hide special menu
		special_menu.hide()
		action_menu.show()
		postAttack()

#
# TARGETING ALLIES
#

# the player presses the party member icon
func _on_party_ui_party_member_pressed(member: CharacterStats, memberIcon: turnIcon) -> void:
	if ally_targeting_mode:
		var caster = turnOrder[0]
		var spell: BaseSpellStrategy = current_ability
		var castSpell = spell.cast(caster, member, memberIcon, null)
		
		if !castSpell[0]:
			$invalid.play()
			message_panel.add_message(castSpell[1])
			return
		
		$heal.play() # possible to include sound effect in the spell
		# Message
		var message = "Turn %s: [color=green]%s[/color] uses [color=yellow]%s[/color] on [color=green]%s[/color]" % [
			turn, caster.character_name, spell.name, member.character_name
		]
		message += castSpell[1]
		message_panel.add_message(message)

		# Hide menus
		special_menu.hide()
		action_menu.show()

		# Reset targeting state
		current_ability = null
		ally_targeting_mode = false
		party_ui.clear_highlights()

		# Update UI
		party_ui.update_status()

		# Move caster to end of turn order
		turnOrder.push_back(turnOrder.pop_front())

		# Announce next turn
		_announce_next_turn()

		# Check for end of combat (optional, in case you have win/lose conditions)
		_check_combat_end()
		
		
func _end_combat():
	print("Combat ended — returning to overworld.")
	$"..".queue_free()  # This will remove this combat scene from the tree


func _on_inventory_ui_item_hovered(item: Variant) -> void:
	description.text = item.effectText()


func _on_party_ui_party_member_item_heal_completed(target, item) -> void:
	
	var message = "Turn %s: [color=green]%s[/color] uses [color=yellow]%s[/color] on [color=green]%s[/color]" % [
		turn, turnOrder[0].character_name, item.item_name, target.character_name
	]
	
	message += item.combatText()
	message_panel.add_message(message)
	
	# reset the targeting of allies
	party_ui.targetSelectable = false
	party_ui.clear_highlights()
	
	# Hide menus
	item_menu.hide()
	action_menu.show()
	
	# Move caster to end of turn order
	turnOrder.push_back(turnOrder.pop_front())

	# Announce next turn
	_announce_next_turn()

	# Check for end of combat (optional, in case you have win/lose conditions)
	_check_combat_end()
