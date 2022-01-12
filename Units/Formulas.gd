class_name Formulas
extends Reference

#Formulas an be extended with attack_data later to account for weaknesses 

static func calculate_potential_damage(action_data, attacker) -> float:	
	return attacker.stats.attack * action_data.damage_multiplier


static func calculate_base_damage(action_data, attacker, defender) -> int:
	var damage: float = calculate_potential_damage(action_data, attacker)
	#damage -= defender.stats.defense
	return int(clamp(damage, 1.0, 999.0))

static func calculate_hit_chance(action_data, attacker, defender) -> float:
	var chance: float = attacker.stats.hit_chance - defender.stats.evasion
	chance *= action_data.hit_chance / 100.0
	return clamp(chance, 0.0, 100.0)
