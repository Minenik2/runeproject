extends Node
class_name Maze_Builder

@export var gridmap: GridMap  # Assign your GridMap node in the Inspector

func build_maze(maze: Labyrinth):
	gridmap.clear()  # Clear previous maze data

	for x in range(maze.width):
		for y in range(maze.height):
			var tile_position = Vector3(x * maze.tile_scale, 0, y * maze.tile_scale)  # Y=0 since it's a flat maze

			if maze.maze[x][y] == 1:
				gridmap.set_cell_item(tile_position, 1)  # Wall tile
			else:
				gridmap.set_cell_item(tile_position, 0)  # Floor tile
