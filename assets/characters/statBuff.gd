class_name StatBuff
extends Resource

enum BuffType {
	MULTIPLY,
	ADD
}

@export var stat: CharacterStats.BUFFABLE_STATS
@export var buff_amount: float
@export var buff_type: BuffType

func _init(_stat: CharacterStats.BUFFABLE_STATS = CharacterStats.BUFFABLE_STATS.max_hp, 
_buff_amount: float = 1.0, _buff_type: StatBuff.BuffType = BuffType.MULTIPLY) -> void:
	stat = _stat
	buff_type = _buff_type
	buff_amount = _buff_amount
