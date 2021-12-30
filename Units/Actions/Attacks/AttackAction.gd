# Concrete class for basic damaging attacks. Inflicts direct damage to one or more targets.
class_name AttackAction
extends Action

var _hits := []


func _init(data: AttackActionData, actor, targets: Array).(data, actor, targets) -> void:
	pass


# Plays the acting battler's attack animation once for each target. Damages each target when the actor's animation emits the `triggered` signal.
func _apply_async() -> bool:
	for target in _targets:	
	
		var hit_chance := Formulas.calculate_hit_chance(_data, _actor, target)
		var damage := calculate_hit_damage(target)
		var hit := Hit.new(damage, hit_chance)
	return true


func _on_BattlerAnim_triggered(target, hit: Hit) -> void:
	target.take_hit(hit)


func calculate_hit_damage(target) -> int:
	return Formulas.calculate_base_damage(_data, _actor, target)


func get_damage_multiplier() -> float:
	return _data.damage_multiplier


func get_element() -> int:
	return _data.element


func get_hit_chance() -> int:
	return _data.hit_chance
