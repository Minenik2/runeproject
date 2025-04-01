extends CharacterBody3D

@export var speed: float = 1.5
var direction = Vector3.ZERO
var target_tile = Vector2.ZERO
var grid_size = 1
@onready var labyrinth_generator = $"../../../labyrinth_generator"

func _ready():
	randomize()
	pick_new_target()

func _physics_process(delta):
	if direction != Vector3.ZERO:
		velocity = direction * speed
		move_and_slide()

		# Check if close to the target tile
		var current_tile = Vector2(global_position.x, global_position.z)
		if current_tile.distance_to(target_tile) < 0.1:
			pick_new_target()

func pick_new_target():
	# Pick a random new direction
	var possible_moves = [Vector3.FORWARD, Vector3.BACK, Vector3.LEFT, Vector3.RIGHT]
	possible_moves.shuffle()

	for move in possible_moves:
		var new_position = global_position + move * grid_size
		var tile = Vector2(new_position.x, new_position.z)
		if is_walkable(tile):
			target_tile = tile
			direction = move
			return

	# If no valid move, stop
	direction = Vector3.ZERO

func is_walkable(tile):
	# Check with the labyrinth generator if the tile is walkable
	return labyrinth_generator.maze[tile.x][tile.y] == 0
