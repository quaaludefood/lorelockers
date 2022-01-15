# Data container used to construct [AttackAction] objects.
class_name AttackActionData
extends ActionData

export var damage_multiplier := 1.0
export var hit_chance := 100.0
export var is_spawning := false

func calculate_potential_damage_for(battler) -> int:
	var total_damage: int = int(Formulas.calculate_potential_damage(self, battler))
	return total_damage
