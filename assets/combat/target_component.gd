extends Node

signal newtarget

# when the player clicks on the enemy
func _on_enemy_clicked(event: InputEvent, enemy_sprite: TextureRect):
	if event is InputEventMouseButton and event.pressed:
		Music.play_ui_hit_combat()
		newtarget.emit()
		enemy_sprite.showTarget()
