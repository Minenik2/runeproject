extends Node

const COMBAT_SCENE = preload("res://assets/combat/combatScene.tscn")
var current_enemy: Node = null
var giveXP = 100

var enemiesRes: Array[CharacterStats] = []
var enemyStrength = 5

func make_combat(enemy: Node):
	# When the player touches an enemy or enters a zone, transition to combat
	if get_tree().paused:
		return  # already in combat
	
	get_tree().paused = true
	
	current_enemy = enemy  # Save reference to the enemy
	enemiesRes = spawn_random_enemies()
	
	print("Combat triggered!")
	var combat_instance = COMBAT_SCENE.instantiate()
	get_tree().root.add_child(combat_instance)  # Add to the root to load the combat UI

func combat_ended():
	if current_enemy:
		current_enemy.queue_free()
		current_enemy = null
		
	get_node("/root/Node3D/UI/PartyUIOverworld").update_status()
	get_node("/root/Node3D/UI/menuUI/VBoxContainer/TabBar").update_status()
	
	get_tree().paused = false

func spawn_random_enemies():
	var randomi = randi_range(0,2)
	
	if Database.depth % 5 == 0:
		enemyStrength += 1
	
	if randomi == 2:
		enemiesRes.append(create_goblin(enemyStrength - 2))  # Add goblin to the array.
		enemiesRes.append(create_goblin(enemyStrength - 2))  # Add another goblin to the array.
		giveXP = 50  # Set XP for this encounter.
	else:
		enemiesRes.append(create_goblin(enemyStrength))
		giveXP = 25
	
	return enemiesRes
	
func create_goblin(stat):
	var goblin = preload("res://assets/characters/enemies/goblin.tres").duplicate(true)
	goblin.strength = stat
	goblin.intelligence = stat
	goblin.vitality = stat
	goblin.dexterity = stat
	goblin.faith = stat
	goblin.speed = stat
	
	goblin.calculate_derived_stats()
	return goblin

func get_xp_for_enouncter():
	return giveXP * randf_range(0.8, 1.2)

var sfx_player: AudioStreamPlayer
var victory = preload("res://assets/audio/victory.ogg")

func _ready():
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)

func play_sfx(stream: AudioStream):
	sfx_player.stream = stream
	sfx_player.play()
	
func play_victory():
	sfx_player.volume_db = -20
	play_sfx(victory)
