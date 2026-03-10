extends Resource
class_name BaseUpgradeStrategy

@export var icon: CompressedTexture2D
@export var rarity: RARITY = RARITY.COMMON
	
enum RARITY {
	COMMON,
	RARE,
	LEGENDARY
}

func applyUpgrade(character: CharacterStats):
	return

func description() -> String:
	return "if you're reading this, it's a bug"
