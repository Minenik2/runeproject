# CombatManager.gd
extends Node

# Node References
@onready var current_member_display = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/currentPlayerInfo"
@onready var action_menu = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/actionMenu"
@onready var enemy_container = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/enemyGroup"
@onready var party_ui: GridContainer = $"../CanvasLayer/UI/PanelContainer/VBoxContainer/content/PartyUI"

# Combat Variables
var party_members = ["player", "miku", "felipe", "mio"]
var enemies = ["goblin", "goblin"]
var memberRes = []
var enemiesRes = []
var targeting_mode = false

# Resource paths
const CHARACTER_PATH = "res://assets/characters/heroes/"
const ENEMY_PATH = "res://assets/characters/enemies/"

func _ready() -> void:
	start_combat()

func start_combat():
	for member_name in party_members:
		memberRes.append(load(CHARACTER_PATH + member_name + ".tres"))
		
	# load it in the player party visualizer
	party_ui.initialize(memberRes) 
	
	# Clear current display
	for child in enemy_container.get_children():
		child.queue_free()
	
	# load and display enemies
	for enemy_name in enemies:
		var enemy_sprite = TextureRect.new()
		var current_enemy = load(ENEMY_PATH + enemy_name + ".tres").duplicate()
		enemy_sprite.texture = current_enemy.battle_sprite
		enemy_sprite.connect("gui_input", Callable(self, "_on_enemy_clicked").bind(enemy_sprite))
		enemy_container.add_child(enemy_sprite)
		enemiesRes.append(current_enemy)
	

func _set_current_member_display(member_name: String):
	current_member_display.clear()  # Remove previous sprite if needed
	var sprite = Sprite2D.new()
	sprite.texture = load(CHARACTER_PATH + member_name + ".png")
	current_member_display.add_child(sprite)

func _on_attack_button_pressed() -> void:
	print("Attack pressed — choose a target")
	targeting_mode = true
	_highlight_enemies(true)


func _on_item_button_pressed() -> void:
	print("item!")
	
func _on_enemy_clicked(event: InputEvent, enemy_sprite: TextureRect):
	if targeting_mode and event is InputEventMouseButton and event.pressed:
		print("Attacked enemy: ", enemy_sprite)
		enemy_sprite.queue_free()  # Example: "kill" the enemy
		targeting_mode = false
		_highlight_enemies(false)
	
	
func _highlight_enemies(active: bool):
	for enemy in enemy_container.get_children():
		enemy.modulate = Color(1, 0.5, 0.5) if active else Color(1, 1, 1)
