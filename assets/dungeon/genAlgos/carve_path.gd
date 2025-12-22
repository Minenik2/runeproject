extends Node
class_name carve_path

var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

func carve_path(mazeCube: Labyrinth, pos):
	mazeCube.maze[pos.x][pos.y] = 0  # Mark as path
	directions.shuffle()  # Randomize directions

	for dir in directions:
		var next_pos = pos + dir * 2  # Move 2 steps in a direction
		if is_within_bounds(mazeCube, next_pos) and is_within_bounds(mazeCube, (pos + dir)) and mazeCube.maze[next_pos.x][next_pos.y] == 1:
			var between = (pos + next_pos) / 2
			mazeCube.maze[between.x][between.y] = 0  # Remove wall between
			carve_path(mazeCube, next_pos)

func is_within_bounds(mazeCube: Labyrinth, pos):
	return pos.x > 0 and pos.x < mazeCube.width - 1 and pos.y > 0 and pos.y < mazeCube.height - 1
