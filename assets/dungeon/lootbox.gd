extends Node3D

@onready var maze_generator: Node = $"../../labyrinth_generator"
@onready var minimap: Control = $"../../UI/Minimap"
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var depth_ui: Label = get_node("/root/Node3D/UI/depthUI")
@onready var tooltip: Label = get_node("/root/Node3D/UI/tooltip_middle")
@onready var popup: Control = get_node("/root/Node3D/UI/text_popup")

const MESSAGE_LABEL = preload("res://assets/combat/floating_damage_label.tscn")

var minimap_icon = "exit"
var player_in_range = false
var player_ref: CharacterBody3D = null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		$Sprite3D.hide()
		Music.play_movedExit()
		tooltip.text = "Press SPACE to open chest"
		tooltip.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		if tooltip.text == "Press SPACE to open chest":
			tooltip.hide()
		$Sprite3D.show()
		

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		Music.play_chestOpen()
		
		var message = Database.roll_chest_loot()
		
		var floating_message = MESSAGE_LABEL.instantiate()
		popup.add_child(floating_message)
		floating_message.global_position = popup.global_position
		floating_message.show_message(message.text, message.rarity)
		popup.show()
		
		queue_free()
