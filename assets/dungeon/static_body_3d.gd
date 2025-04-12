extends StaticBody3D

@export var open_rotation: float = 90.0  # Degrees to rotate when opened
@export var is_open: bool = false  # Track door state

@onready var anim_player = $"../AnimationPlayer"  # Reference to the animation player

func _ready():
	create_animation()  # Create the animation when the scene loads

func interact():
	is_open = !is_open
	if is_open:
		$CollisionShape3D.disabled = true  # Disable collision when open
		anim_player.play("open")
	else:
		$CollisionShape3D.disabled = false  # Enable collision when closed
		anim_player.play("close")

func create_animation():
	var anim = Animation.new()
	
	# Open animation
	anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(0, "Door:rotation_degrees:y")  # Rotate around Y axis
	anim.track_insert_key(0, 0.0, 0)  # Start at 0 degrees
	anim.track_insert_key(0, 0.5, open_rotation)  # Rotate to open_rotation over 0.5s
	anim.set_length(0.5)

	var close_anim = anim.duplicate()  # Duplicate for close animation
	close_anim.track_set_key_value(0, 1, 0)  # Rotate back to 0 degrees

	var anim_lib = AnimationLibrary.new()
	anim_lib.add_animation("open", anim)
	anim_lib.add_animation("close", close_anim)
	
	$"../AnimationPlayer".add_animation_library("", anim_lib)
