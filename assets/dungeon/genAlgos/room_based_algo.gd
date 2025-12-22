extends Node
class_name room_based_algo

# ROOM BASED ALGORITHM
func room_based_algorithm(mazeCube: Labyrinth):
	# Fill everything with walls
	for x in range(mazeCube.width):
		for y in range(mazeCube.height):
			mazeCube.maze[x][y] = 1

	var rooms = []
	var max_rooms = 6
	var min_room_size = 3
	var max_room_size = 5

	for i in range(max_rooms):
		var room_width = randi_range(min_room_size, max_room_size)
		var room_height = randi_range(min_room_size, max_room_size)

		var room_x = randi_range(1, mazeCube.width - room_width - 2)
		var room_y = randi_range(1, mazeCube.height - room_height - 2)

		var new_room = Rect2(room_x, room_y, room_width, room_height)

		# Check for overlap
		var overlaps = false
		for other_room in rooms:
			if new_room.intersects(other_room.grow(1)):
				overlaps = true
				break

		if not overlaps:
			create_room(mazeCube, new_room)
			if rooms.size() > 0:
				# Connect this room to the previous one
				var prev_center = rooms[rooms.size() - 1].get_center()
				var new_center = new_room.get_center()
				create_hallway(mazeCube, prev_center, new_center)

			rooms.append(new_room)

	# Enclose the maze with outer walls
	for x in range(mazeCube.width):
		mazeCube.maze[x][0] = 1
		mazeCube.maze[x][mazeCube.height - 1] = 1
	for y in range(mazeCube.height):
		mazeCube.maze[0][y] = 1
		mazeCube.maze[mazeCube.width - 1][y] = 1

func create_room(mazeCube: Labyrinth, room: Rect2):
	for x in range(room.position.x, room.position.x + room.size.x):
		for y in range(room.position.y, room.position.y + room.size.y):
			mazeCube.maze[x][y] = 0

func create_hallway(mazeCube: Labyrinth, from_pos: Vector2, to_pos: Vector2):
	from_pos = from_pos.floor()
	to_pos = to_pos.floor()

	if randi() % 2 == 0:
		# Horizontal then vertical
		for x in range(min(from_pos.x, to_pos.x), max(from_pos.x, to_pos.x) + 1):
			mazeCube.maze[x][from_pos.y] = 0
		for y in range(min(from_pos.y, to_pos.y), max(from_pos.y, to_pos.y) + 1):
			mazeCube.maze[to_pos.x][y] = 0
	else:
		# Vertical then horizontal
		for y in range(min(from_pos.y, to_pos.y), max(from_pos.y, to_pos.y) + 1):
			mazeCube.maze[from_pos.x][y] = 0
		for x in range(min(from_pos.x, to_pos.x), max(from_pos.x, to_pos.x) + 1):
			mazeCube.maze[x][to_pos.y] = 0
			
## end of room based algorithm
