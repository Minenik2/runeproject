extends Resource
class_name BaseSpawnStrategy

@export var object_scene: PackedScene
@export var object_name: String = "unamed"
@export var min_distance = 4 # min distance between each object
@export var attempts_per_chest = 30 # how many times to randomly attempt spawn before giving up
var spawnedObjects = []

# The base for spawning objects into labyrinths

func spawnObject(mazeCube: Labyrinth,num_chests: int, objectThatSpawns: Node):
	# Remove old chests
	despawn_all_objects()

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
				
				mazeCube.maze[int(spawn_pos.x)][int(spawn_pos.y)] = 3

				var chest = object_scene.instantiate()
				print("%s spawned at " % [object_name], spawn_pos)
				chest.global_position = Vector3(
					(spawn_pos.x + 0.5) * mazeCube.tile_scale,
					0.8,
					(spawn_pos.y + 0.5) * mazeCube.tile_scale
				)
				objectThatSpawns.add_child(chest)
				spawnedObjects.append(chest)

			attempts += 1

	# You can print a warning if not all chests were spawned
	if spawnedObjects.size() < num_chests:
		print("Only spawned %s out of %s %s due to space constraints." % [spawnedObjects.size(), num_chests, object_name])

func despawn_all_objects():
	for chest in spawnedObjects:
		if not is_instance_valid(chest):
			continue
		chest.queue_free()
	spawnedObjects.clear()

func find_random_open_space(mazeCube: Labyrinth, far_from=null) -> Vector2:
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
