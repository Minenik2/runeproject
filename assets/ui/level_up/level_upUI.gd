extends Panel

@onready var level_up_text: Label = $VBoxContainer/levelUpText
@onready var power_up: Button = $VBoxContainer/VBoxContainer/HBoxContainer/powerUP
@onready var power_up_2: Button = $VBoxContainer/VBoxContainer/HBoxContainer/powerUP2
@onready var power_up_3: Button = $VBoxContainer/VBoxContainer/HBoxContainer/powerUP3
@onready var info_label: Label = $VBoxContainer/VBoxContainer/infoLabel
@onready var levelUP_button: Button = %levelUp
@onready var tab_bar: TabBar = $"../menuUI/VBoxContainer/TabBar"

var currentCharacter: CharacterStats = null
var upgrade1: BaseUpgradeStrategy = null
var upgrade2: BaseUpgradeStrategy = null
var upgrade3: BaseUpgradeStrategy = null

var rarity_colors := {
	BaseUpgradeStrategy.RARITY.COMMON: Color(1.0, 1.0, 1.0, 1.0),
	BaseUpgradeStrategy.RARITY.RARE: Color(0.418, 0.567, 0.896, 1.0),
	BaseUpgradeStrategy.RARITY.LEGENDARY: Color(0.785, 0.9, 0.135, 1.0)
}

func _on_power_up_pressed() -> void:
	$"../menuUI/uiHit".play()
	upgrade1.applyUpgrade(currentCharacter)
	tab_bar.update_status()
	hide()

func _on_power_up_2_pressed() -> void:
	$"../menuUI/uiHit".play()
	upgrade2.applyUpgrade(currentCharacter)
	tab_bar.update_status()
	hide()

func _on_power_up_3_pressed() -> void:
	$"../menuUI/uiHit".play()
	upgrade3.applyUpgrade(currentCharacter)
	tab_bar.update_status()
	hide()

#### mouse entered below

func _on_power_up_mouse_entered() -> void:
	info_label.text = upgrade1.description()

func _on_power_up_2_mouse_entered() -> void:
	info_label.text = upgrade2.description()

func _on_power_up_3_mouse_entered() -> void:
	info_label.text = upgrade3.description()


func _on_levelUp_pressed() -> void:
	$"../menuUI/uiHit".play()
	upgrade1 = UpgradeGacha.roll_upgrade_loot()
	
	upgrade2 = UpgradeGacha.roll_upgrade_loot()
	while upgrade2 == upgrade1:
		upgrade2 = UpgradeGacha.roll_upgrade_loot()

	upgrade3 = UpgradeGacha.roll_upgrade_loot()
	while upgrade3 == upgrade1 or upgrade3 == upgrade2:
		upgrade3 = UpgradeGacha.roll_upgrade_loot()
	
	power_up.icon = upgrade1.icon
	power_up.modulate = rarity_colors[upgrade1.rarity]

	power_up_2.icon = upgrade2.icon
	power_up_2.modulate = rarity_colors[upgrade2.rarity]

	power_up_3.icon = upgrade3.icon
	power_up_3.modulate = rarity_colors[upgrade3.rarity]
	
	currentCharacter = tab_bar.selectedMemberVisual
	currentCharacter.level_up_points -= 1
	level_up_text.text = "%s leveled up! - Choose an upgrade" % [currentCharacter.character_name]
	
	show()
