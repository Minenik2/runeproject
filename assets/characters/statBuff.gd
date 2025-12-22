class_name StatBuff
extends Resource

enum BuffType {
	MULTIPLY,
	ADD
}

# when does the buff disappear?
enum BUFFLAST {
	NEXT_DEPTH,
	COMBAT_END
}

@export var stat: CharacterStats.BUFFABLE_STATS
@export var buff_amount: float
@export var buff_type: BuffType

func _init(_stat: CharacterStats.BUFFABLE_STATS = CharacterStats.BUFFABLE_STATS.max_hp, 
_buff_amount: float = 1.0, _buff_type: StatBuff.BuffType = BuffType.MULTIPLY) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount

func tooltip() -> String:
	var buffText = ""
	match stat:
		CharacterStats.BUFFABLE_STATS.attack_power:
			buffText = "Attack Damage"
		CharacterStats.BUFFABLE_STATS.defense:
			buffText = "Defense"
		CharacterStats.BUFFABLE_STATS.max_hp:
			buffText = "Max HP"
	if buff_type == BuffType.ADD:
		return "Increased %s by +%s" % [buffText, buff_amount]
	else:
		var precentile = buff_amount * 10
		return "Increased %s by %s%" % [buffText, precentile]
