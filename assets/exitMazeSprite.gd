extends Sprite3D

@onready var player = $"../../../player"  # Adjust path

func _process(delta):
	if player:
		look_at(player.global_transform.origin, Vector3.UP)
