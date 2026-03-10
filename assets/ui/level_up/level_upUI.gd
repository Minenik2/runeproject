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
	upgrade3 = UpgradeGacha.roll_upgrade_loot()
	currentCharacter = tab_bar.selectedMemberVisual
	currentCharacter.level_up_points -= 1
	show()
