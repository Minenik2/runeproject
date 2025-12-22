extends Node

signal newtarget

var currentTarget: enemyIcon

# when the player clicks on the enemy it sets it as a target
func _on_enemy_clicked(event: InputEvent, enemy_sprite: enemyIcon):
	if event is InputEventMouseButton and event.pressed:
		Music.play_ui_hit_combat()
		newtarget.emit()
		enemy_sprite.showTarget()
		currentTarget = enemy_sprite

# when the target dies a new one will be selected
func selectTarget(enemy):
	currentTarget = enemy
	currentTarget.showTarget()
