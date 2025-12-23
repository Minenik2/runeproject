extends Node

@export var maze_reset_scene: PackedScene  # Assign your .tscn file here
@export var player: CharacterBody3D
var maze_reset_instance: Node3D  # To store the instance of the reset object


func spawn_player(mazeCube: Labyrinth):
	# Spawn player at calculated spawn point
	player.global_position = Vector3((mazeCube.spawn_point.x + 0.5) * mazeCube.tile_scale,
	0.8,
	(mazeCube.spawn_point.y + 0.5) * mazeCube.tile_scale)
	
	# Spawn or move the maze reset object
	spawn_maze_reset_object(mazeCube)

func spawn_maze_reset_object(mazeCube: Labyrinth):
	if not maze_reset_scene:
		print("Maze Reset Scene is not assigned!")
		return

	# Remove the old instance if it exists
	if maze_reset_instance:  
		maze_reset_instance.queue_free()
		maze_reset_instance = null  

	# Instantiate the new reset object
	maze_reset_instance = maze_reset_scene.instantiate()

	# Add it to the same parent as the gridmap (or use another relevant node)
	$"..".add_child(maze_reset_instance)
	maze_reset_instance.global_position = Vector3(
		(mazeCube.exit_point.x + 0.5) * mazeCube.tile_scale, 
		0.8,  
		(mazeCube.exit_point.y + 0.5) * mazeCube.tile_scale
	)
