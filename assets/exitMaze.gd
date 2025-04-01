extends Area3D

@onready var maze_generator: Node = $"../../../labyrinth_generator"
@onready var minimap: Control = $"../../../UI/Minimap"


func _on_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("player"):
		body.is_moving = false
		maze_generator.generate_maze()  # Generate new maze
		maze_generator.build_maze()  # Apply the new maze
		maze_generator.print_maze()
		minimap.reset_minimap()
