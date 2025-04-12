extends Control

@export var dungeon_map: TextureRect  # UI Texture for the minimap
@export var player_marker: TextureRect  # The fixed player pointer
@export var grid_size: float = 1.0  # World space size per tile
@export var minimap_scale: float = 20.0  # Scale for rendering
@export var labyrinth_generator: Node  # Reference to the labyrinth generator
@export var player: Node
@export var zoom: float = 1.5


@onready var margin_container: MarginContainer = $MarginContainer
@onready var mob_marker: TextureRect = $MarginContainer/CenterContainer/maptexture/mobMarker
@onready var exit_marker: TextureRect = $MarginContainer/CenterContainer/maptexture/exitMarker
@onready var icons = {"enemy": mob_marker, "exit": exit_marker}

var explored_tiles = {}  # Dictionary to store explored tiles
var maze = []  # Holds the labyrinth structure
var minimap_size = 11  # 5 tiles in each direction + player tile
var markers = {} # keys are the actuall object and the values are the markers assigned to them

func _ready():
	# Fetch the generated maze from the Labyrinth Generator
	if labyrinth_generator:
		maze = labyrinth_generator.maze
	else:
		print("ERROR: Labyrinth Generator not assigned!")
	get_markers()
		
func _process(delta):
	update_minimap()

func update_minimap():
	if maze.is_empty():
		return  # Prevent errors if maze isn't set

	var player_tile = world_to_tile(player.global_transform.origin)

	# Reveal tiles as player moves
	reveal_tiles_around(player_tile)

	# Create a small minimap around the player (11x11)
	var img = Image.create(minimap_size, minimap_size, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)  # Default to unexplored

	for dx in range(-5, 6):  
		for dy in range(-5, 6):
			var tile = player_tile + Vector2(dx, dy)
			if is_within_bounds(tile) and explored_tiles.has(tile) and explored_tiles[tile]:
				var color = Color.WHITE if maze[tile.x][tile.y] == 0 else Color.GRAY
				img.set_pixel(dx + 5, dy + 5, color)  # Center player on minimap

	# Show enemies
	for enemy in labyrinth_generator.enemies:
		var enemy_tile = world_to_tile(enemy.global_position)
		var relative_pos = enemy_tile - player_tile
		if abs(relative_pos.x) <= 5 and abs(relative_pos.y) <= 5:
			img.set_pixel(relative_pos.x + 5, relative_pos.y + 5, Color.RED)  # Enemy is red

	# Update minimap texture
	var texture = ImageTexture.create_from_image(img)
	dungeon_map.texture = texture

	# Update player marker
	player_marker.rotation_degrees = -player.rotation_degrees.y  # Rotate based on player direction
	for item in markers:
		if not is_instance_valid(item):
			continue  # Skip this item if it has been freed
		
		var obj_tile = world_to_tile(item.global_transform.origin)
		var relative_pos = obj_tile - player_tile  # Calculate relative position in tiles

		var final_pos = relative_pos * minimap_scale + dungeon_map.size / 2  # Scale to minimap
		var local_final_pos = final_pos - dungeon_map.position  # Convert to local coords
		final_pos.x = clamp(final_pos.x, 0, dungeon_map.size.x)
		final_pos.y = clamp(final_pos.y, 0, dungeon_map.size.y)
		
		final_pos.x -= 8
		final_pos.y -= 8

		markers[item].position = final_pos  # Assign to marker
		if Rect2(Vector2.ZERO, dungeon_map.size).has_point(local_final_pos):
			markers[item].show()
		else:
			markers[item].hide()

func reveal_tiles_around(center_tile):
	# Reveal a 5x5 area around the player
	for dx in range(-2, 3):
		for dy in range(-2, 3):
			var tile = center_tile + Vector2(dx, dy)
			if is_within_bounds(tile):
				explored_tiles[tile] = true  # Mark as explored

func world_to_tile(world_pos):
	# Convert world coordinates to tile coordinates
	return Vector2(int(world_pos.x) / grid_size, int(world_pos.z) / grid_size)

func is_within_bounds(tile):
	return tile.x >= 0 and tile.x < maze.size() and tile.y >= 0 and tile.y < maze[0].size()
	
func reset_minimap():
	maze = labyrinth_generator.maze
	explored_tiles.clear()  # Clear all previous exploration data

	# Make all tiles unexplored at the start
	for x in range(maze.size()):  
		for y in range(maze[0].size()):  
			explored_tiles[Vector2(x, y)] = false  

	# Reveal only the starting position of the player
	var player_tile = world_to_tile($"../../player".global_transform.origin)
	reveal_tiles_around(player_tile)

	get_markers()
	#print("current markers", markers)

func get_markers():
	# Free only the markers that were added
	for marker in markers.values():
		if is_instance_valid(marker):  # Check if it's not already freed
			marker.queue_free()
	
	markers.clear()  # Clear the dictionary since markers are now freed
	
	var map_objects = get_tree().get_nodes_in_group("minimap_objects")
	for item in map_objects:
		#print(item.minimap_icon, icons)
		var new_marker = icons[item.minimap_icon].duplicate()
		dungeon_map.add_child(new_marker)
		new_marker.show()
		markers[item] = new_marker
