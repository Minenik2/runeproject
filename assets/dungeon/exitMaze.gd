extends Node3D

@onready var maze_generator: Node = $"../../labyrinth_generator"
@onready var minimap: Control = $"../../UI/Minimap"
@onready var sprite_3d: Sprite3D = $Sprite3D
@onready var depth_ui: Label = get_node("/root/Node3D/UI/depthUI")
@onready var tooltip: Label = get_node("/root/Node3D/UI/tooltip_middle")

var minimap_icon = "exit"
var player_in_range = false
var player_ref: CharacterBody3D = null

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		$Sprite3D.hide()
		Music.play_movedExit()
		tooltip.text = "Press SPACE to decent"
		tooltip.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		if tooltip.text == "Press SPACE to decent":
			tooltip.hide()
		player_in_range = false
		player_ref = null
		$Sprite3D.show()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		# Example "interact" is your Input Map action
		_generate_new_maze()

func _generate_new_maze() -> void:
	Database.depth += 1
	depth_ui.text = "Depth: %s" % Database.depth
	
	if player_ref:
		player_ref.is_moving = false
	
	maze_generator.generate_new_maze()
	remove_from_group("minimap_objects")
	minimap.reset_minimap()
