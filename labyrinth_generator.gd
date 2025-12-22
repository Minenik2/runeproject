extends Node
class_name Maze_Generator

@export var player: CharacterBody3D
#@export var width: int = Database.labWidth  # Maze width
#@export var height: int = Database.labHeight  # Maze height
@export var grid_size: float = 2.0  # World space size per tile
@export var maze_reset_scene: PackedScene  # Assign your .tscn file here
@export var enemy_scene: PackedScene  # Assign your enemy scene in the inspector
@export var chest_scene: PackedScene  # Assign your chest scene in the inspector

var labMaze: Labyrinth = Labyrinth.new()

#var maze = labMaze.maze  # 2D array to store walls & paths
#var spawn_point: Vector2
#var exit_point: Vector2
#var tile_scale = 1  # Scale factor
var maze_reset_instance: Node3D  # To store the instance of the reset object
var explored_tiles = labMaze.explored_tiles  # Stores explored tiles for fog of war
var enemies = []  # Store enemy instances
var chests = [] # store chests instances

var enemiesCounter = Database.enemiesCounter
var chestCounter = Database.chestCounter



func _ready():
	generate_new_maze()
	
# this function is called by mazeExit everytime the player wants to decent
func generate_new_maze():
	if Database.depth % 3 == 0:
		Database.labWidth += 1
	if Database.depth % 6 == 0:
		Database.labHeight += 1
	if Database.depth % 10 == 0:
		Database.enemiesCounter += 1
		Database.chestCounter += 1
	
	labMaze = Labyrinth.new()
	labMaze.width = Database.labWidth
	labMaze.height = Database.labHeight
	enemiesCounter = Database.enemiesCounter
	chestCounter = Database.chestCounter
	
	labMaze = generate_maze(labMaze)
	$labyrinth_builder.build_maze(labMaze)
	spawn_player(labMaze)
	spawn_enemies(labMaze, enemiesCounter)
	spawn_chests(labMaze, chestCounter)  # Spawn 2 chests as a test
	print_maze(labMaze)  # Debug output

func generate_maze(mazeCube: Labyrinth) -> Labyrinth:
	$unlock.play()
	mazeCube.maze = []
	mazeCube.explored_tiles = []  # Reset explored tiles properly
	for x in mazeCube.width:
		mazeCube.maze.append([])
		mazeCube.explored_tiles.append([])  # Initialize the explored_tiles structure
		for y in mazeCube.height:
			mazeCube.maze[x].append(1)  # Fill maze with walls
			mazeCube.explored_tiles[x].append(false)  # Mark all as unexplored

	var algorithm = randi() % 3
	if algorithm == 0:
		print("used carve path")
		$generators/carve_path.carve_path(mazeCube, Vector2(1, 1))  # Recursive Backtracking
	elif algorithm == 1:
		$generators/prims_algo.prims_algorithm(labMaze)
		print("used prims algorithm")
	else:
		$generators/room_based_algo.room_based_algorithm(labMaze)
		print("used room based algorithm")

	# Find a random open space for spawn and exit
	mazeCube.spawn_point = find_random_open_space(mazeCube)
	mazeCube.exit_point = find_random_open_space(mazeCube, mazeCube.spawn_point)

	# Mark exit in maze (for debugging)
	mazeCube.maze[mazeCube.exit_point.x][mazeCube.exit_point.y] = 2  # Exit tile (2)
	
	return mazeCube

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
	add_child(maze_reset_instance)
	maze_reset_instance.global_position = Vector3(
		(mazeCube.exit_point.x + 0.5) * mazeCube.tile_scale, 
		0.8,  
		(mazeCube.exit_point.y + 0.5) * mazeCube.tile_scale
	)

func find_random_open_space(mazeCube: Labyrinth, far_from=null):
	var open_spaces = []
	for x in mazeCube.width:
		for y in mazeCube.height:
			if mazeCube.maze[x][y] == 0:  # Only consider walkable paths
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

func print_maze(mazeCube: Labyrinth):
	for row in mazeCube.maze:
		var row_string = ""
		for cell in row:
			if cell == 1:
				row_string += "#"
			elif cell == 0:
				row_string += "."
			else:
				row_string += "x"
		print(row_string)

func spawn_player(mazeCube: Labyrinth):
	# Spawn player at calculated spawn point
	player.global_position = Vector3((mazeCube.spawn_point.x + 0.5) * mazeCube.tile_scale,
	0.8,
	(mazeCube.spawn_point.y + 0.5) * mazeCube.tile_scale)
	
	# Spawn or move the maze reset object
	spawn_maze_reset_object(mazeCube)

func spawn_enemies(mazeCube: Labyrinth, num_enemies: int):
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
			var spawn_pos = find_random_open_space(mazeCube)
			var too_close = false

			# Check against player spawn position
			if mazeCube.spawn_point.distance_to(spawn_pos) < min_distance:
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
					(spawn_pos.x + 0.5) * mazeCube.tile_scale,
					0.8,
					(spawn_pos.y + 0.5) * mazeCube.tile_scale
				)
				add_child(enemy)
				enemies.append(enemy)

			attempts += 1

	# You can print a warning if not all enemies were spawned
	if enemies.size() < num_enemies:
		print("Only spawned %d out of %d enemies due to space constraints." % [enemies.size(), num_enemies])

# function to spawn chests
func spawn_chests(mazeCube: Labyrinth,num_chests: int):
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
			var spawn_pos = find_random_open_space(mazeCube)
			var too_close = false

			# Check distance from player
			if mazeCube.spawn_point.distance_to(spawn_pos) < min_distance:
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
					(spawn_pos.x + 0.5) * mazeCube.tile_scale,
					0.8,
					(spawn_pos.y + 0.5) * mazeCube.tile_scale
				)
				add_child(chest)
				chests.append(chest)

			attempts += 1

	# You can print a warning if not all chests were spawned
	if chests.size() < num_chests:
		print("Only spawned %d out of %d chests due to space constraints." % [chests.size(), num_chests])
