extends Node3D

@onready var maze_generator: Node = $"../../labyrinth_generator"
@onready var minimap: Control = $"../../UI/Minimap"
@onready var sprite_3d: Sprite3D = $Sprite3D

var minimap_icon = "exit"

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		body.is_moving = false
		maze_generator.generate_maze()  # Generate new maze
		maze_generator.build_maze()  # Apply the new maze
		maze_generator.print_maze()
		remove_from_group("minimap_objects")
		minimap.reset_minimap()
