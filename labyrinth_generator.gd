extends Node

@export var player: CharacterBody3D
@export var width: int = 10  # Maze width
@export var height: int = 10  # Maze height
@export var grid_size: float = 2.0  # World space size per tile
@export var maze_reset_scene: PackedScene  # Assign your .tscn file here
@export var enemy_scene: PackedScene  # Assign your enemy scene in the inspector
@export var gridmap: GridMap  # Assign your GridMap node in the Inspector

var maze = []  # 2D array to store walls & paths
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var spawn_point: Vector2
var exit_point: Vector2
var tile_scale = 1  # Scale factor
var maze_reset_instance: Node3D  # To store the instance of the reset object
var explored_tiles = []  # Stores explored tiles for fog of war
var enemies = []  # Store enemy instances

func _ready():
	generate_maze()
	build_maze()
	spawn_enemies(3)
	print_maze()  # Debug output

func generate_maze():
	maze = []
	explored_tiles = []  # Reset explored tiles properly
	for x in width:
		maze.append([])
		explored_tiles.append([])  # Initialize the explored_tiles structure
		for y in height:
			maze[x].append(1)  # Fill maze with walls
			explored_tiles[x].append(false)  # Mark all as unexplored

	var algorithm = randi() % 3
	if algorithm == 0:
		print("used carve path")
		carve_path(Vector2(1, 1))  # Recursive Backtracking
	elif algorithm == 1:
		prims_algorithm()
		print("used prims algorithm")
	else:
		binary_tree_algorithm()
		print("used binary tree algorithm")

	# Find a random open space for spawn and exit
	spawn_point = find_random_open_space()
	exit_point = find_random_open_space(spawn_point)

	# Mark exit in maze (for debugging)
	maze[exit_point.x][exit_point.y] = 2  # Exit tile (2)
	
	

func find_random_open_space(far_from=null):
	var open_spaces = []
	for x in width:
		for y in height:
			if maze[x][y] == 0:  # Only consider walkable paths
				open_spaces.append(Vector2(x, y))

	if open_spaces.is_empty():
		return Vector2(1, 1)  # Default if no valid space is found

	# If we need to pick a location far from another point, ensure it's different
	if far_from:
		var valid_spaces = []
		for pos in open_spaces:
			if pos != far_from:
				valid_spaces.append(pos)

		# Sort by farthest from 'far_from'
		valid_spaces.sort_custom(func(a, b): return a.distance_to(far_from) > b.distance_to(far_from))

		if not valid_spaces.is_empty():
			return valid_spaces[0]  # Pick the farthest valid space

	return open_spaces[0]  # Default to the first open space

func carve_path(pos):
	maze[pos.x][pos.y] = 0  # Mark as path
	directions.shuffle()  # Randomize directions

	for dir in directions:
		var next_pos = pos + dir * 2  # Move 2 steps in a direction
		if is_within_bounds(next_pos) and is_within_bounds((pos + dir)) and maze[next_pos.x][next_pos.y] == 1:
			var between = (pos + next_pos) / 2
			maze[between.x][between.y] = 0  # Remove wall between
			carve_path(next_pos)

func prims_algorithm():
	var walls = []
	var start = Vector2(1, 1)
	maze[start.x][start.y] = 0

	for dir in directions:
		var neighbor = start + dir * 2
		var between = start + dir  # The wall between two paths
		if is_within_bounds(neighbor) and is_within_bounds(between):
			walls.append(neighbor)

	while walls.size() > 0:
		walls.shuffle()
		var wall = walls.pop_back()
		if is_within_bounds(wall) and maze[wall.x][wall.y] == 1:
			var neighbors = []
			for dir in directions:
				var neighbor = wall + dir * 2
				if is_within_bounds(neighbor) and maze[neighbor.x][neighbor.y] == 0:
					neighbors.append(neighbor)

			if neighbors.size() > 0:
				var chosen = neighbors.pick_random()
				maze[wall.x][wall.y] = 0
				var between = (wall + chosen) / 2
				maze[between.x as int][between.y as int] = 0
				for dir in directions:
					var new_wall = wall + dir * 2
					if is_within_bounds(new_wall) and maze[new_wall.x][new_wall.y] == 1:
						walls.append(new_wall)

func binary_tree_algorithm():
	for x in range(width):
		maze[x][0] = 1  # Top border
		maze[x][height - 1] = 1  # Bottom border

	for y in range(height):
		maze[0][y] = 1  # Left border
		maze[width - 1][y] = 1  # Right border
	
	for x in range(0, width, 2):
		for y in range(0, height, 2):
			maze[x][y] = 0
			if x > 0 and y > 0:
				if randi() % 2 == 0:
					maze[x - 1][y] = 0
				else:
					maze[x][y - 1] = 0

func is_within_bounds(pos):
	return pos.x > 0 and pos.x < width - 1 and pos.y > 0 and pos.y < height - 1

func print_maze():
	for row in maze:
		var row_string = ""
		for cell in row:
			if cell == 1:
				row_string += "#"
			elif cell == 0:
				row_string += "."
			else:
				row_string += "x"
		print(row_string)

func build_maze():
	gridmap.clear()  # Clear previous maze data

	for x in range(width):
		for y in range(height):
			var tile_position = Vector3(x * tile_scale, 0, y * tile_scale)  # Y=0 since it's a flat maze

			if maze[x][y] == 1:
				gridmap.set_cell_item(tile_position, 1)  # Wall tile
			else:
				gridmap.set_cell_item(tile_position, 0)  # Floor tile
	
	# Spawn player at calculated spawn point
	player.global_position = Vector3((spawn_point.x + 0.5) * tile_scale,
	0.8,
	(spawn_point.y + 0.5) * tile_scale)
	
	# Spawn or move the maze reset object
	spawn_maze_reset_object()

func spawn_maze_reset_object():
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
	gridmap.add_child(maze_reset_instance)
	maze_reset_instance.global_position = Vector3(
		(exit_point.x + 0.5) * tile_scale, 
		0.8,  
		(exit_point.y + 0.5) * tile_scale
	)

func spawn_enemies(num_enemies: int):
	# Remove old enemies
	for enemy in enemies:
		enemy.queue_free()
	enemies.clear()

	# Spawn new enemies
	for i in range(num_enemies):
		var enemy = enemy_scene.instantiate()
		var spawn_pos = find_random_open_space()
		enemy.global_position = Vector3(spawn_pos.x * grid_size + 0.5, 0.8, spawn_pos.y * grid_size + 0.5)
		add_child(enemy)
		enemies.append(enemy)
