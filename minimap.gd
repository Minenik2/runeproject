extends Control

@export var dungeon_map: TextureRect  # UI Texture for the minimap
@export var player_marker: TextureRect  # The fixed player pointer
@export var grid_size: float = 1.0  # World space size per tile
@export var minimap_scale: float = 10.0  # Scale for rendering
@export var labyrinth_generator: Node  # Reference to the labyrinth generator

var explored_tiles = {}  # Dictionary to store explored tiles
var maze = []  # Holds the labyrinth structure
var minimap_size = 11  # 5 tiles in each direction + player tile

func _ready():
	# Fetch the generated maze from the Labyrinth Generator
	if labyrinth_generator:
		maze = labyrinth_generator.maze
	else:
		print("ERROR: Labyrinth Generator not assigned!")

func _process(delta):
	update_minimap()

func update_minimap():
	if maze.is_empty():
		return  # Prevent errors if the maze isn't set

	var player = $"../../player"
	var player_tile = world_to_tile(player.global_transform.origin)

	# Reveal tiles as player moves
	reveal_tiles_around(player_tile)

	# Create a small minimap around the player (11x11)
	var img = Image.create(minimap_size, minimap_size, false, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)  # Default to unexplored

	for dx in range(-5, 6):  # 5 tiles in each direction
		for dy in range(-5, 6):
			var tile = player_tile + Vector2(dx, dy)
			if is_within_bounds(tile):
				if explored_tiles.has(tile):  # Show only explored tiles
					var color = Color.WHITE if maze[tile.x][tile.y] == 0 else Color.GRAY
					img.set_pixel(dx + 5, dy + 5, color)  # Center player on minimap

	# Update minimap position so the player stays centered
	#dungeon_map.position = -player_tile * minimap_scale + Vector2(dungeon_map.size.x / 2, dungeon_map.size.y / 2)

	# Update player marker
	player_marker.rotation_degrees = -player.rotation_degrees.y  # Rotate based on player direction

	# Update minimap texture
	var texture = ImageTexture.create_from_image(img)
	dungeon_map.texture = texture

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
