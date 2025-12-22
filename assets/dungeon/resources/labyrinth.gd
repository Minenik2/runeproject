extends Resource
class_name Labyrinth

@export var width: int = 10 # Maze width
@export var height: int = 10  # Maze height

var maze = []  # 2D array to store walls & paths
var tile_scale = 1  # Scale factor
var spawn_point: Vector2
var exit_point: Vector2
var explored_tiles = []  # Stores explored tiles for fog of war
