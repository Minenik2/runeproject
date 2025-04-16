extends TabBar

func _ready() -> void:
	for c in Database.memberRes:
		var button = Button.new()
		button.text = c.character_name
		# Optionally connect a pressed signal if you want interaction:
		button.pressed.connect(_on_character_button_pressed.bind(c))
		$"../statsPanel/VBoxContainer".add_child(button)
		$"../statsPanel/VBoxContainer".move_child(button, $"../statsPanel/VBoxContainer".get_children().find($"../statsPanel/VBoxContainer".get_node("Button")))
	
	populate_stats(Database.memberRes[0])
	

func _update_visible_panel(tab: int):
	$"../statsPanel".visible = (tab == 0)
	#$AbilitiesPanel.visible = (tab == 1)

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
	$"../statsPanel".visible = (tab == 0)

func _unhandled_input(event):
	if event.is_action_pressed("pause"):  # ui_cancel is Esc by default
		$"../../uiHit".play()
		var menu_ui = $"../.."
		menu_ui.visible = not menu_ui.visible


func _on_button_pressed() -> void:
	$"../../uiHit".play()
	$"../..".hide()
