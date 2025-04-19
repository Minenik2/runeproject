# CharacterStats.gd
extends Resource
class_name CharacterStats

enum CHARACTER_CLASS {
	Warrior,    # High HP/Strength
	Arcanist,       # High MP/Intelligence
	Rogue,      # High Dexterity/Speed
	Cleric,     # Balanced Faith/Vitality
	Vampire     # Hybrid Strength/Faith
}

@export_category("Basic Info")
@export var character_name: String = "Unnamed"
@export var battle_sprite: Texture
@export var character_class: CHARACTER_CLASS = CHARACTER_CLASS.Warrior

@export_category("Window Stats")
@export var level: int = 1
@export var max_hp: int = 100
@export var current_hp: int = 100
@export var max_mp: int = 30
@export var current_mp: int = 30

@export_category("Core Stats")
@export var strength: int = 10
@export var intelligence: int = 9
@export var vitality: int = 9
@export var dexterity: int = 9
@export var faith: int = 9
@export var speed: int = 9

@export_category("Leveling")
@export var experience: int = 0
@export var experience_to_level: int = 100

@export var abilities: Array[Ability] = []

# Derived stats (no @export since they're calculated)
var attack_power: int
var magic_power: int
var accuracy: float
var defense: int
var magic_defense: int
var evasion: float
var critical_chance: float
var critical_multiplier: float
var combat_initiative : int
var is_ally: bool
var is_dead: bool = false

# Initialize with default values
func _init():
	current_hp = max_hp
	current_mp = max_mp
	calculate_derived_stats()

func calculate_derived_stats():
	# HP/MP Formulas
	max_hp = floor((vitality + (strength * 0.5)) * 5)
	max_mp = floor((intelligence + faith))
	
	# Offensive Stats
	attack_power = floor(
		strength + 
		dexterity
	)
	
	magic_power = floor(
		intelligence + 
		faith
	)
	
	# Accuracy and Evasion (competing stats)
	var base_accuracy = 0.82
	accuracy = clamp(
		base_accuracy + 
		(1.0 - pow(0.93, dexterity)) - 
		(0.0005 * pow(dexterity, 1.5)),
		0.65, 0.98
	)
	
	# Defense Formulas (armor and magic resistance)
	defense = floor(
		vitality * 1.4 + 
		strength * 0.6
	)
	
	magic_defense = floor(
		intelligence * 1.1 + 
		faith * 1.1 + 
		vitality * 0.3
	)
	
	# Evasion and Criticals
	evasion = clamp(
		0.05 + 
		(dexterity * 0.0075) - 
		(strength * 0.0005) -
		(vitality * 0.0003),
		0.01, 0.35
	)
	
	critical_chance = 0.03 + (dexterity * 0.006) + (level * 0.001)
	critical_multiplier = 1.6 + (dexterity * 0.01) + (faith * 0.005)
	
	# Special Bonuses (synergistic effects)
	var strength_vitality_bonus = 1.0 + min(strength, vitality) * 0.002
	var int_faith_bonus = 1.0 + (intelligence * faith) * 0.0001
	
	# Final Adjustments
	attack_power *= strength_vitality_bonus
	magic_power *= int_faith_bonus
	defense *= strength_vitality_bonus
	magic_defense *= int_faith_bonus
	
	# make sure values down overdo
	current_hp = min(current_hp, max_hp)
	current_mp = min(current_mp, max_mp)

func calculate_exp_to_level() -> int:
	experience_to_level = experience_to_level + 5
	if level % 11 == 0:
		experience_to_level = experience_to_level / 2
	
	return experience_to_level


func gain_exp(amount: int) -> bool:
	experience += amount
	print(character_name, " gained ", amount, " xp. Total ", experience, "/", experience_to_level)
	if experience >= experience_to_level:
		level_up()
		return true
	return false

func level_up():
	level += 1
	# check if the target leveled up naturally or by other means such as using an item
	if experience >= experience_to_level:
		experience =  experience - experience_to_level
	else:
		experience = 0
	experience_to_level = calculate_exp_to_level()
	
	# Class-based stat growth
	match character_class:
		CHARACTER_CLASS.Warrior:
			strength += randi_range(1, 2)
		CHARACTER_CLASS.Arcanist:
			intelligence += randi_range(1, 2)
		CHARACTER_CLASS.Rogue:
			dexterity += randi_range(1, 2)
		CHARACTER_CLASS.Cleric:
			faith += randi_range(1, 2)
		CHARACTER_CLASS.Vampire:
			speed += randi_range(1, 2)
	
	var current_max_hp = max_hp
	var current_max_mp = max_mp
	
	calculate_derived_stats()  # Recalculate everything
	
	# increase health because of level up if not dead
	if not is_dead:
		current_hp += max_hp - current_max_hp
		current_mp += max_mp - current_max_mp
		current_hp = min(current_hp, max_hp)
		current_mp = min(current_mp, max_mp)
	
	print("%s leveled up to %d!" % [character_name, level])
	
	# final check to see if the target has xp to level again in case of a huge xp surge
	if experience >= experience_to_level:
		level_up()


# Helper methods
func take_damage(amount: int) -> void:
	current_hp = max(current_hp - amount, 0)
	print(character_name, " took ", amount, " damage! HP: ", current_hp, "/", max_hp)

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	print(character_name, " healed ", amount, " HP! HP: ", current_hp, "/", max_hp)

func use_mp(amount: int) -> bool:
	if current_mp >= amount:
		current_mp -= amount
		return true
	return false

func is_alive() -> bool:
	return current_hp > 0

# Calculate initiative for turn order (higher is better)
func calculate_initiative() -> int:
	combat_initiative = speed + randi() % 6 # Add small random variance
	return combat_initiative  
