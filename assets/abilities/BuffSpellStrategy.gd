extends BaseSpellStrategy
class_name BuffSpellStrategy

@export var statBuff = CharacterStats.BUFFABLE_STATS.attack_power
@export var buffAmount: float
@export var buffType = StatBuff.BuffType.ADD

var newBuff: StatBuff
var buffedTargets: Array[CharacterStats]

func _init() -> void:
	setup_buff.call_deferred()
	
func setup_buff() -> void:
	newBuff = StatBuff.new(statBuff,buffAmount,buffType)

func cast(caster: CharacterStats, reciever: CharacterStats, _characterIcon: turnIcon, _enemy_sprite: enemyIcon) -> Array:
	if target_type == TARGETING_TYPE.SELFCAST:
		if caster.stat_buffs.has(newBuff):
			return [false, "You already have the buff."]
		caster.add_buff(newBuff)
		buffedTargets.append(caster)
	else:
		if reciever.stat_buffs.has(newBuff):
			return [false, "Target already has the buff."]
		reciever.add_buff(newBuff)
		buffedTargets.append(reciever)
	
	return [true, "casted this ability"]

func removeBuff(target: CharacterStats):
	target.remove_buff(newBuff)

# removes this buff from all the targets that has it
func removeAllBuffs():
	for target in buffedTargets:
		target.remove_buff(newBuff)

func combatText():
	var buffText = ""
	match statBuff:
		CharacterStats.BUFFABLE_STATS.attack_power:
			buffText = "Attack Damage"
		CharacterStats.BUFFABLE_STATS.defense:
			buffText = "Defense"
		CharacterStats.BUFFABLE_STATS.max_hp:
			buffText = "Max HP"
	
	return ", gaining +%s %s" % [buffAmount, buffText]
