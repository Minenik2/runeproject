extends Resource
class_name SpellUnlockEntry

@export var ability: BaseSpellStrategy  # The shared skill
@export var unlock_level: int = 2 # Character-specific requirement
