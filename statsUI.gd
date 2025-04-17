extends TabBar

var targetAlly: bool = false
var selectedSpell
var currentCaster

const FLOATING_DAMAGE_LABEL = preload("res://assets/combat/floating_damage_label.tscn")

func _ready() -> void:
	for c in Database.memberRes:
		var button = Button.new()
		button.text = c.character_name
		# Optionally connect a pressed signal if you want interaction:
		button.pressed.connect(_on_character_button_pressed.bind(c))
		$"../statsPanel/VBoxContainer".add_child(button)
		
		var icon = preload("res://TurnIcon.tscn").instantiate()
		icon.set_combatant(c)
		
		# Connect the signal to a local handler function in CombatScene
		icon.icon_pressed.connect(Callable(self, "_on_party_icon_pressed"))
		$"../spellPanel/HBoxContainer/hbox/CharactersContainer".add_child(icon)
	populate_stats(Database.memberRes[0])
	

func _update_visible_panel(tab: int):
	$"../statsPanel".visible = (tab == 0)
	$"../spellPanel".visible = (tab == 1)
	$"../inventoryPanel".visible = (tab == 2)

func _on_character_button_pressed(c):
	$"../../uiHit".play()
	populate_stats(c)

func populate_stats(c):
	$"../statsPanel/VBoxContainer2/TextureRect".texture = c.battle_sprite
	$"../statsPanel/VBoxContainer2/heroName".text = c.character_name
	$"../statsPanel/VBoxContainer2/lvl".text = "Lv. %s" % c.level
	$"../statsPanel/VBoxContainer2/exp".text = "Exp: %s / %s" % [c.experience, c.experience_to_level]
	$"../statsPanel/VBoxContainer2/hp".text = "HP: %s / %s" % [c.current_hp, c.max_hp]
	$"../statsPanel/VBoxContainer2/Mp".text = "MP: %s / %s" % [c.current_mp, c.max_mp]
	
	# Primary stats
	$"../statsPanel/VBoxContainer/strength".text = "Strength: %s" % c.strength
	$"../statsPanel/VBoxContainer/intelligence".text = "Intelligence: %s" % c.intelligence
	$"../statsPanel/VBoxContainer/vitality".text = "Vitality: %s" % c.vitality
	$"../statsPanel/VBoxContainer/dexterity".text = "Dexterity: %s" % c.dexterity
	$"../statsPanel/VBoxContainer/faith".text = "Faith: %s" % c.faith
	$"../statsPanel/VBoxContainer/speed".text = "Speed: %s" % c.speed
	
	# Class
	$"../statsPanel/VBoxContainer/class".text = "Class: %s" % c.CHARACTER_CLASS.keys()[c.character_class]


func _on_tab_changed(tab: int) -> void:
	$"../../uiHit".play()
	_update_visible_panel(tab)

func _input(event):
	if event.is_action_pressed("pause"):  # ui_cancel is Esc by default
		$"../../uiHit".play()
		populate_stats(Database.memberRes[0])
		update_status()
		var menu_ui = $"../.."
		menu_ui.visible = not menu_ui.visible


func _on_button_pressed() -> void:
	$"../../uiHit".play()
	$"../..".hide()

func _on_party_ui_overworld_party_member_pressed(member: Variant) -> void:
	$"../../uiHit".play()
	populate_stats(member)
	update_status()
	$"../..".show()

func update_status():
	for i in range(Database.memberRes.size()):
		var icon = $"../spellPanel/HBoxContainer/hbox/CharactersContainer".get_child(i)
		icon.set_combatant(Database.memberRes[i])

#
# SPELL MENU SYSTEM
#

func _on_party_icon_pressed(c, sender):
	if targetAlly:
		# check if max health, for healing
		if c.current_hp == c.max_hp:
			$"../../invalid".play()
			$"../spellPanel/info".text = "Target has max HP"
			return
		
		if not _check_if_enough_resources(selectedSpell, currentCaster):
			return
		
		if selectedSpell.mp_cost > 0:
			currentCaster.current_mp -= selectedSpell.mp_cost
		if selectedSpell.sp_cost > 0:
			Database.current_sp -= selectedSpell.sp_cost
		if selectedSpell.hp_cost > 0:
			currentCaster.current_hp -= selectedSpell.hp_cost
		
		if selectedSpell.type == 1:
			
			$"../../uiHeal".play()
			var heal_amount = selectedSpell.calculate_scaled_power(currentCaster)
			c.current_hp = min(c.current_hp + heal_amount, c.max_hp)
			update_status()
			
			sender.show_heal(heal_amount)
			
	else:
		$"../../uiHit".play()
		_update_info_label()
		_clear_spell_buttons()
		
		for spell in c.abilities:
			var spell_button = Button.new()
			spell_button.text = spell.name
			spell_button.pressed.connect(_on_spell_button_pressed.bind(c, spell))
			$"../spellPanel/HBoxContainer/SpellsContainer".add_child(spell_button)
	
func _clear_spell_buttons():
	for child in $"../spellPanel/HBoxContainer/SpellsContainer".get_children():
		child.queue_free()

func _on_spell_button_pressed(caster, spell):
	var char_container = $"../spellPanel/HBoxContainer/hbox/CharactersContainer"
	
	for child in char_container.get_children():
		if child is Button:
			# Found the button — highlight it
			child.modulate = Color(1, 1, 0)  # Yellow
	
	if spell.target_type == 1:
		if not _check_if_enough_resources(spell, caster):
			return
		$"../../uiHit".play()
		
		currentCaster = caster
		selectedSpell = spell
		targetAlly = true
		
		$"../spellPanel/info".text = "Currently Selected: %s" % spell.name
		$"../spellPanel/CancelSpellButton".show()
	else:
		$"../../invalid".play()
		$"../spellPanel/info".text = "Current spell is not a healing spell"

func _check_if_enough_resources(spell, caster):
	if spell.mp_cost > caster.current_mp:
		$"../../invalid".play()
		$"../spellPanel/info".text = "Not enough MP"
		return false
	if spell.sp_cost > Database.current_sp:
		$"../../invalid".play()
		$"../spellPanel/info".text = "Not enough SP"
		return false
	if spell.hp_cost > caster.current_hp:
		$"../../invalid".play()
		$"../spellPanel/info".text = "Not enough HP"
		return false
	return true # enough resources to use this spell

func _update_info_label():
	$"../spellPanel/info".text = "Choose a spell"

func _on_cancel_spell_button_pressed() -> void:
	$"../../uiHit".play()
	currentCaster = null
	selectedSpell = null
	targetAlly = false
	
	$"../spellPanel/info".text = "Choose a spell"
	$"../spellPanel/CancelSpellButton".hide()
