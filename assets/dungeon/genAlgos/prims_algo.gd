extends Node
class_name prims_algo

var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

func prims_algorithm(mazeCube: Labyrinth):
	var walls = []
	var start = Vector2(1, 1)
	mazeCube.maze[start.x][start.y] = 0

	for dir in directions:
		var neighbor = start + dir * 2
		var between = start + dir  # The wall between two paths
		if is_within_bounds(mazeCube, neighbor) and is_within_bounds(mazeCube, between):
			walls.append(neighbor)

	while walls.size() > 0:
		walls.shuffle()
		var wall = walls.pop_back()
		if is_within_bounds(mazeCube, wall) and mazeCube.maze[wall.x][wall.y] == 1:
			var neighbors = []
			for dir in directions:
				var neighbor = wall + dir * 2
				if is_within_bounds(mazeCube, neighbor) and mazeCube.maze[neighbor.x][neighbor.y] == 0:
					neighbors.append(neighbor)

			if neighbors.size() > 0:
				var chosen = neighbors.pick_random()
				mazeCube.maze[wall.x][wall.y] = 0
				var between = (wall + chosen) / 2
				mazeCube.maze[between.x as int][between.y as int] = 0
				for dir in directions:
					var new_wall = wall + dir * 2
					if is_within_bounds(mazeCube, new_wall) and mazeCube.maze[new_wall.x][new_wall.y] == 1:
						walls.append(new_wall)

func is_within_bounds(mazeCube: Labyrinth, pos):
	return pos.x > 0 and pos.x < mazeCube.width - 1 and pos.y > 0 and pos.y < mazeCube.height - 1
