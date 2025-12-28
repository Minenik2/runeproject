extends Sprite3D

@onready var player = $"../../../player"  # Adjust path

func _process(_delta):
	if player and global_position != player.global_position:
		look_at(player.global_position + Vector3(0.001, 0, 0), Vector3.UP)
