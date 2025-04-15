# CharacterStats.gd
extends Resource
class_name CharacterStats

enum CHARACTER_CLASS {
	WARRIOR,    # High HP/Strength
	MAGE,       # High MP/Intelligence
	ROGUE,      # High Dexterity/Speed
	CLERIC,     # Balanced Faith/Vitality
	PALADIN     # Hybrid Strength/Faith
}

@export_category("Basic Info")
@export var character_name: String = "Unnamed"
@export var battle_sprite: Texture
@export var character_class: CHARACTER_CLASS = CHARACTER_CLASS.WARRIOR

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

# Initialize with default values
func _init():
	current_hp = max_hp
	current_mp = max_mp
	calculate_derived_stats()

func calculate_derived_stats():
	# HP/MP Formulas (non-linear scaling)
	max_hp = floor(max_hp + (vitality * 10) + (level * vitality * 0.7) + (strength * 0.5))
	max_mp = floor(max_mp + (intelligence * 8) + (faith * 5) + (level * (intelligence + faith) * 0.2))
	
	# Offensive Stats (with diminishing returns)
	attack_power = floor(
		strength * 1.8 + 
		dexterity * 0.5 + 
		(level * 0.3) * (1 + strength * 0.01)
	)
	
	magic_power = floor(
		intelligence * 2.2 + 
		faith * 1.3 + 
		(level * 0.25) * (1 + (intelligence + faith) * 0.008)
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
		strength * 0.6 + 
		(level * 0.4) * (1 + vitality * 0.015) -
		(dexterity * 0.1)  # Heavy armor reduces dodge
	)
	
	magic_defense = floor(
		intelligence * 1.1 + 
		faith * 1.1 + 
		vitality * 0.3 +
		(level * 0.35) * (1 + (intelligence + faith) * 0.01)
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
	
	# Ensure current values don't exceed new maxima
	current_hp = min(current_hp, max_hp)
	current_mp = min(current_mp, max_mp)


func get_class_modifiers() -> Dictionary:
	match character_class:
		CHARACTER_CLASS.WARRIOR:
			return {
				"hp_mod": 1.3,
				"mp_mod": 0.7,
				"str_mod": 0.4,       # Bonus to physical attacks
				"int_mod": -0.3,      # Penalty to magic
				"dex_mod": -0.1,
				"vit_mod": 0.2,
				"fai_mod": -0.2,
				"growth_bonus": {
					"strength": 1.6,  # 60% stronger growth
					"vitality": 1.3,
					"speed": 0.8      # Warriors are slower
				},
				"armor_penalty": 0.0  # Can wear heavy armor
			}
		
		CHARACTER_CLASS.MAGE:
			return {
				"hp_mod": 0.6,
				"mp_mod": 1.8,
				"str_mod": -0.4,
				"int_mod": 0.5,      # Strong magic focus
				"dex_mod": 0.1,
				"vit_mod": -0.2,
				"fai_mod": 0.1,
				"growth_bonus": {
					"intelligence": 1.8,
					"faith": 1.2,
					"dexterity": 1.1
				},
				"spell_power": 1.25   # Bonus to spell damage
			}
		
		CHARACTER_CLASS.ROGUE:
			return {
				"hp_mod": 0.9,
				"mp_mod": 0.9,
				"str_mod": 0.1,
				"int_mod": -0.1,
				"dex_mod": 0.5,      # Extreme agility focus
				"vit_mod": -0.1,
				"fai_mod": -0.3,
				"growth_bonus": {
					"dexterity": 2.0, # Double dex growth
					"speed": 1.5,
					"strength": 0.7
				},
				"crit_bonus": {       # Special rogue crits
					"chance": 0.10,   # +10% base
					"multiplier": 0.5  # +50% damage
				}
			}
		
		CHARACTER_CLASS.CLERIC:
			return {
				"hp_mod": 1.1,
				"mp_mod": 1.3,
				"str_mod": -0.1,
				"int_mod": 0.2,
				"dex_mod": -0.2,
				"vit_mod": 0.3,
				"fai_mod": 0.4,       # Strong faith focus
				"growth_bonus": {
					"faith": 1.7,
					"vitality": 1.4,
					"intelligence": 1.2
				},
				"healing_power": 1.3, # Better healing
				"undead_damage": 1.5  # Bonus vs undead
			}
		
		CHARACTER_CLASS.PALADIN:
			return {
				"hp_mod": 1.2,
				"mp_mod": 1.1,
				"str_mod": 0.3,
				"int_mod": -0.1,
				"dex_mod": -0.3,
				"vit_mod": 0.4,
				"fai_mod": 0.3,       # Hybrid warrior/cleric
				"growth_bonus": {
					"strength": 1.3,
					"faith": 1.4,
					"vitality": 1.3
				},
				"holy_power": 1.2,    # Holy damage bonus
				"armor_penalty": -0.1 # Reduced dodge penalty
			}
		
		_: # Default (Adventurer)
			return {
				"hp_mod": 1.0,
				"mp_mod": 1.0,
				"growth_bonus": {
					"strength": 1.0,
					"intelligence": 1.0,
					"vitality": 1.0,
					"dexterity": 1.0,
					"faith": 1.0,
					"speed": 1.0
				}
			}

func calculate_exp_to_level() -> int:
	# Exponential curve with class adjustment
	var base_exp = pow(level, 2) * 100
	match character_class:
		CHARACTER_CLASS.WARRIOR: return base_exp * 0.9    # Warriors level slightly faster
		CHARACTER_CLASS.MAGE: return base_exp * 1.1       # Mages need more XP
		_: return base_exp


func gain_exp(amount: int) -> bool:
	experience += amount
	if experience >= experience_to_level:
		level_up()
		return true
	return false

func level_up():
	level += 1
	experience -= calculate_exp_to_level()
	
	# Class-based stat growth
	var growth_bonus = get_class_modifiers().get("growth_bonus", {})
	
	strength += roundi((randi() % 3 + 1) * growth_bonus.get("strength", 1.0))
	vitality += roundi((randi() % 2 + 1) * growth_bonus.get("vitality", 1.0))
	intelligence += roundi((randi() % 3 + 1) * growth_bonus.get("intelligence", 1.0))
	dexterity += roundi((randi() % 2 + 1) * growth_bonus.get("dexterity", 1.0))
	faith += roundi((randi() % 2 + 1) * growth_bonus.get("faith", 1.0))
	speed += roundi((randi() % 2 + 1) * growth_bonus.get("speed", 1.0))
	
	calculate_derived_stats()  # Recalculate everything
	
	# Heal on level up
	current_hp = max_hp
	current_mp = max_mp
	
	print("%s leveled up to %d!" % [character_name, level])


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
	combat_initiative = speed + randi() % 5 # Add small random variance
	return combat_initiative  
