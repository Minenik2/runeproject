extends Node

@export var player: CharacterBody3D
@export var width: int = 10  # Maze width
@export var height: int = 10  # Maze height
@export var grid_size: float = 2.0  # World space size per tile
@export var maze_reset_scene: PackedScene  # Assign your .tscn file here
@export var enemy_scene: PackedScene  # Assign your enemy scene in the inspector
@export var gridmap: GridMap  # Assign your GridMap node in the Inspector
@export var chest_scene: PackedScene  # Assign your chest scene in the inspector

var maze = []  # 2D array to store walls & paths
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]
var spawn_point: Vector2
var exit_point: Vector2
var tile_scale = 1  # Scale factor
var maze_reset_instance: Node3D  # To store the instance of the reset object
var explored_tiles = []  # Stores explored tiles for fog of war
var enemies = []  # Store enemy instances
var chests = [] # store chests instances

func _ready():
	generate_new_maze()
	
# this function is called by mazeExit everytime the player wants to decent
func generate_new_maze():
	generate_maze()
	build_maze()
	spawn_enemies(3)
	spawn_chests(2)  # Spawn 2 chests as a test
	#print_maze()  # Debug output

func generate_maze():
	$unlock.play()
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
		room_based_algorithm()
		print("used room based algorithm")

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

	open_spaces.shuffle()

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

# ROOM BASED ALGORITHM
func room_based_algorithm():
	# Fill everything with walls
	for x in range(width):
		for y in range(height):
			maze[x][y] = 1

	var rooms = []
	var max_rooms = 6
	var min_room_size = 3
	var max_room_size = 5

	for i in range(max_rooms):
		var room_width = randi_range(min_room_size, max_room_size)
		var room_height = randi_range(min_room_size, max_room_size)

		var room_x = randi_range(1, width - room_width - 2)
		var room_y = randi_range(1, height - room_height - 2)

		var new_room = Rect2(room_x, room_y, room_width, room_height)

		# Check for overlap
		var overlaps = false
		for other_room in rooms:
			if new_room.intersects(other_room.grow(1)):
				overlaps = true
				break

		if not overlaps:
			create_room(new_room)
			if rooms.size() > 0:
				# Connect this room to the previous one
				var prev_center = rooms[rooms.size() - 1].get_center()
				var new_center = new_room.get_center()
				create_hallway(prev_center, new_center)

			rooms.append(new_room)

	# Enclose the maze with outer walls
	for x in range(width):
		maze[x][0] = 1
		maze[x][height - 1] = 1
	for y in range(height):
		maze[0][y] = 1
		maze[width - 1][y] = 1

func create_room(room: Rect2):
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			maze[x][y] = 0

func create_hallway(from_pos: Vector2, to_pos: Vector2):
	from_pos = from_pos.floor()
	to_pos = to_pos.floor()

	if randi() % 2 == 0:
		# Horizontal then vertical
		for x in range(min(from_pos.x, to_pos.x), max(from_pos.x, to_pos.x) + 1):
			maze[x][from_pos.y] = 0
		for y in range(min(from_pos.y, to_pos.y), max(from_pos.y, to_pos.y) + 1):
			maze[to_pos.x][y] = 0
	else:
		# Vertical then horizontal
		for y in range(min(from_pos.y, to_pos.y), max(from_pos.y, to_pos.y) + 1):
			maze[from_pos.x][y] = 0
		for x in range(min(from_pos.x, to_pos.x), max(from_pos.x, to_pos.x) + 1):
			maze[x][to_pos.y] = 0
			
## end of room based algorithm

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
		if not is_instance_valid(enemy):
			continue
		enemy.queue_free()
	enemies.clear()

	var min_distance = 5
	var attempts_per_enemy = 30  # Max attempts before giving up on placing an enemy

	# Track placed positions (in tile coords)
	var placed_positions = []

	for i in range(num_enemies):
		var attempts = 0
		var found = false

		while attempts < attempts_per_enemy and not found:
			var spawn_pos = find_random_open_space()
			var too_close = false

			# Check against player spawn position
			if spawn_point.distance_to(spawn_pos) < min_distance:
				too_close = true

			# Check against other enemies
			for pos in placed_positions:
				if pos.distance_to(spawn_pos) < min_distance:
					too_close = true
					break

			if not too_close:
				found = true
				placed_positions.append(spawn_pos)

				var enemy = enemy_scene.instantiate()
				print("enemy spawned at ", spawn_pos)
				enemy.global_position = Vector3(
					(spawn_pos.x + 0.5) * tile_scale,
					0.8,
					(spawn_pos.y + 0.5) * tile_scale
				)
				add_child(enemy)
				enemies.append(enemy)

			attempts += 1

	# You can print a warning if not all enemies were spawned
	if enemies.size() < num_enemies:
		print("Only spawned %d out of %d enemies due to space constraints." % [enemies.size(), num_enemies])

# function to spawn chests
func spawn_chests(num_chests: int):
	# Remove old chests
	for chest in chests:
		if not is_instance_valid(chest):
			continue
		chest.queue_free()
	chests.clear()

	var min_distance = 4
	var attempts_per_chest = 30
	var placed_positions = []

	for i in range(num_chests):
		var attempts = 0
		var found = false

		while attempts < attempts_per_chest and not found:
			var spawn_pos = find_random_open_space()
			var too_close = false

			# Check distance from player
			if spawn_point.distance_to(spawn_pos) < min_distance:
				too_close = true

			# Check distance from other chests
			for pos in placed_positions:
				if pos.distance_to(spawn_pos) < min_distance:
					too_close = true
					break

			if not too_close:
				found = true
				placed_positions.append(spawn_pos)

				var chest = chest_scene.instantiate()
				print("chest spawned at ", spawn_pos)
				chest.global_position = Vector3(
					(spawn_pos.x + 0.5) * tile_scale,
					0.8,
					(spawn_pos.y + 0.5) * tile_scale
				)
				add_child(chest)
				chests.append(chest)

			attempts += 1

	# You can print a warning if not all chests were spawned
	if chests.size() < num_chests:
		print("Only spawned %d out of %d chests due to space constraints." % [chests.size(), num_chests])
