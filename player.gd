extends CharacterBody3D

@export var grid_size: float = 1.0
@export var turn_speed: float = 90.0 # Degrees per turn
@export var collision_check_distance: float = 1.0  # Same as grid_size
@export var move_speed: float = 10.0  # Speed of movement transition
@export var rotate_speed: float = 10.0  # Speed of rotation transition
@onready var minimap: Control = $"../UI/Minimap"

var direction = Vector3.FORWARD
var target_position: Vector3
var target_rotation: float
var is_moving: bool = false
var is_rotating: bool = false

func _ready():
	target_position = global_transform.origin
	target_rotation = rotation.y

func _input(event):
	if event is InputEventKey and event.pressed and not is_moving:
		if event.is_action("up"):
			move_forward()
		elif event.is_action_pressed("left"):
			rotate_left()
		elif event.is_action_pressed("right"):
			rotate_right()
		elif event.is_action_pressed("interact"):  # Press 'E' to interact
			interact_with_object()

func _process(delta):
	if is_moving:
		global_transform.origin = global_transform.origin.lerp(target_position, move_speed * delta)
		if global_transform.origin.distance_to(target_position) < 0.1:
			global_transform.origin = target_position
			is_moving = false
	
	if is_rotating:
		rotation.y = lerp_angle(rotation.y, target_rotation, rotate_speed * delta)
		if abs(rotation.y - target_rotation) < 0.01:
			rotation.y = target_rotation
			is_rotating = false
		update_direction() # Update direction only after rotation is finished

func move_forward():
	#make_combat()
	var new_position = global_transform.origin + direction * grid_size
	#print("moving to: ", new_position)

	# Check for collision before moving
	if not is_wall_in_front():
		target_position = new_position
		is_moving = true
		$AudioStreamPlayer3D.play()

func rotate_left():
	target_rotation += deg_to_rad(turn_speed)
	is_rotating = true

func rotate_right():
	target_rotation -= deg_to_rad(turn_speed)
	is_rotating = true

func update_direction():
	direction = Vector3.FORWARD.rotated(Vector3.UP, target_rotation)  # Update forward direction based on rotation
	#direction = -global_transform.basis.z  # Use negative Z as forward

func is_wall_in_front() -> bool:
	var space_state = get_world_3d().direct_space_state
	var ray_origin = global_transform.origin
	var ray_end = ray_origin + direction * collision_check_distance

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = false  # Only collide with static bodieswa
	query.collision_mask = 0b1111111111111101  # Ignores layer 2 (bit 2 = 0)

	var result = space_state.intersect_ray(query)

	return result.size() > 0  # If something is hit, return true (wall detected)
	
func interact_with_object():
	var space_state = get_world_3d().direct_space_state
	var ray_origin = global_transform.origin
	var ray_end = ray_origin + direction * 1.5  # Slightly ahead of the player

	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)

	if result.has("collider") and result.collider.has_method("interact"):
		result.collider.interact()  # Call interact() on the hit object

	
	
