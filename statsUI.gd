extends TabBar

var targetAlly: bool = false
var selectedSpell
var currentCaster

var selectedMemberVisual = Database.memberRes[0] # user clicked on a member

const FLOATING_DAMAGE_LABEL = preload("res://assets/combat/floating_damage_label.tscn")
@onready var party_showcase_ui: GridContainer = $"../inventoryPanel/HBoxContainer/partyShowcaseUI"

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
	selectedMemberVisual = c
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
	update_status()

func _input(event):
	if event.is_action_pressed("pause"):  # ui_cancel is Esc by default
		$"../../uiHit".play()
		update_status()
		var menu_ui = $"../.."
		menu_ui.visible = not menu_ui.visible


func _on_button_pressed() -> void:
	$"../../uiHit".play()
	$"../..".hide()

func _on_party_ui_overworld_party_member_pressed(member: Variant) -> void:
	$"../../uiHit".play()
	selectedMemberVisual = member
	update_status()
	$"../..".show()

func update_status():
	populate_stats(selectedMemberVisual)
	
	$"../../../PartyUIOverworld".update_status()
	
	for i in range(Database.memberRes.size()):
		var icon = $"../spellPanel/HBoxContainer/hbox/CharactersContainer".get_child(i)
		icon.set_combatant(Database.memberRes[i])
	
	$"../inventoryPanel/HBoxContainer/partyShowcaseUI".update_status()
	$"../inventoryPanel/HBoxContainer/inventoryUI".update_inventory()

#
# SPELL MENU SYSTEM
#

func _on_party_icon_pressed(c, sender):
	if targetAlly:
		# check if dead
		if c.is_dead:
			$"../../invalid".play()
			$"../spellPanel/info".text = "Cannot use on the dead"
			return
		
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
	
	if caster.is_dead:
		$"../../invalid".play()
		$"../spellPanel/info".text = "Caster is dead"
		return
	
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


func _on_inventory_ui_item_hovered(item: Variant) -> void:
	$"../inventoryPanel/title".text = item.description
	$"../inventoryPanel/info".text = ""
	if item.hp_restore > 0:
		$"../inventoryPanel/info".text += "Restores %s health points upon use. " % item.hp_restore
	if item.mp_restore > 0:
		$"../inventoryPanel/info".text += "Restores %s mana points upon use. " % item.mp_restore
	if item.increase_level:
		$"../inventoryPanel/info".text += "Increases level by 1 upon use. "


func _on_party_showcase_ui_party_member_pressed(member: Variant, sender) -> void:
	if party_showcase_ui.targetSelectable:
		# if the party ui is pressed while a item has been selected
		if party_showcase_ui.selectedItem:
			var item = party_showcase_ui.selectedItem
	
			# Check if this item restores HP or MP, and if the target is already at max for both
			var restores_hp = item.hp_restore > 0
			var restores_mp = item.mp_restore > 0
			var hp_full = member.current_hp == member.max_hp
			var mp_full = member.current_mp == member.max_mp
			
			# Block if trying to heal a dead person
			if member.is_dead and (restores_hp or restores_mp or item.increase_level):
				$"../../invalid".play()
				$"../inventoryPanel/tooltip".text = "Cannot use on the dead"
				return
					
			# If the item restores either HP or MP, and both are already full, block it
			if (restores_hp or restores_mp) and ((restores_hp and hp_full) and (restores_mp and mp_full)):
				$"../../invalid".play()
				$"../inventoryPanel/tooltip".text = "Target has max HP and MP"
				return
			elif restores_hp and hp_full and not restores_mp:
				$"../../invalid".play()
				$"../inventoryPanel/tooltip".text = "Target has max HP"
				return
			elif restores_mp and mp_full and not restores_hp:
				$"../../invalid".play()
				$"../inventoryPanel/tooltip".text = "Target has max MP"
				return
			
			# Apply item effects
			if restores_hp:
				sender.show_heal(item.hp_restore)
			if restores_mp:
				sender.show_heal(item.mp_restore) # TODO: color this blue
			if item.increase_level:
				sender.show_heal(1) # TODO: color this purple
			
			$"../../uiHeal".play()
			
			party_showcase_ui.selectedItem.use(member)
			if party_showcase_ui.selectedItem.amount_held < 1:
				party_showcase_ui.selectedItem = null
				party_showcase_ui.targetSelectable = false
				$"../inventoryPanel/tooltip".text = "Select an item"
				party_showcase_ui.clear_highlights()
		
		party_showcase_ui.update_status()
		$"../inventoryPanel/HBoxContainer/inventoryUI".update_inventory()
	


func _on_party_showcase_ui_sendt_message(message: Variant) -> void:
	$"../inventoryPanel/tooltip".text = message
