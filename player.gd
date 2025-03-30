extends CharacterBody3D

@export var grid_size: float = 1.0
@export var turn_speed: float = 90.0 # Degrees per turn
@export var collision_check_distance: float = 1.0  # Same as grid_size

var direction = Vector3.FORWARD

func _unhandled_input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_W:
			move_forward()
		elif event.keycode == KEY_A:
			rotate_left()
		elif event.keycode == KEY_D:
			rotate_right()

func move_forward():
	var new_position = global_transform.origin + direction * grid_size

	# Check for collision before moving
	if not is_wall_in_front():
		global_transform.origin = new_position

func rotate_left():
	rotate_y(deg_to_rad(turn_speed))
	update_direction()

func rotate_right():
	rotate_y(deg_to_rad(-turn_speed))
	update_direction()

func update_direction():
	direction = -global_transform.basis.z  # Use negative Z as forward

func is_wall_in_front() -> bool:
	var space_state = get_world_3d().direct_space_state
	var ray_origin = global_transform.origin
	var ray_end = ray_origin + direction * collision_check_distance

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = false  # Only collide with static bodies

	var result = space_state.intersect_ray(query)

	return result.size() > 0  # If something is hit, return true (wall detected)
