class_name Hit
extends Reference

var damage := 0
var hit_chance: float


func _init(_damage: int, _hit_chance := 100.0) -> void:
	damage = _damage
	hit_chance = _hit_chance


func does_hit() -> bool:
	return randf() * 100.0 < hit_chance
