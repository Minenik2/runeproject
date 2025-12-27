extends Area3D

var player_in_range = false
var player_ref: CharacterBody3D = null

@onready var tooltip: Label = get_node("/root/Node3D/UI/tooltip_middle")

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		player_in_range = true
		player_ref = body
		$Sprite3D.hide()
		Music.play_movedExit()
		tooltip.text = "Press SPACE to open shop"
		tooltip.show()

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is CharacterBody3D and body.is_in_group("player"):
		player_in_range = false
		player_ref = null
		if tooltip.text == "Press SPACE to open shop":
			tooltip.hide()
		$Sprite3D.show()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		$enterShop.play()
		ShopUi.show()
