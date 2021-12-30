class_name UnitStats
extends Resource

# Emitted when a character has no `health` left.
signal health_depleted
# Emitted every time the value of `health` changes.
# We will use it to animate the life bar.
signal health_changed(old_value, new_value)

export var max_health := 100.0
export var base_attack := 10.0 setget set_base_attack
export var base_defense := 10.0 setget set_base_defense
export var base_speed := 70.0 setget set_base_speed
export var base_hit_chance := 100.0 setget set_base_hit_chance
export var base_evasion := 0.0 setget set_base_evasion

var attack := base_attack
var defense := base_defense
var speed := base_speed
var hit_chance := base_hit_chance
var evasion := base_evasion

var health := max_health setget set_health

func reinitialize() -> void:
	set_health(max_health)
	
func _recalculate_and_update(stat: String) -> void:
	#This can be extended with the Modifiers thing from stat-bonuses-and-penalties lesson
	var value: float = get("base_" + stat)
	set(stat, value)
	

func set_health(value: float) -> void:
	var health_previous := health
	health = clamp(value, 0.0, max_health)
	emit_signal("health_changed", health_previous, health)
	if is_equal_approx(health, 0.0):
		emit_signal("health_depleted")

func set_base_attack(value: float) -> void:
	base_attack = value
	_recalculate_and_update("attack")


func set_base_defense(value: float) -> void:
	base_defense = value
	_recalculate_and_update("defense")


func set_base_speed(value: float) -> void:
	base_speed = value
	_recalculate_and_update("speed")


func set_base_hit_chance(value: float) -> void:
	base_hit_chance = value
	_recalculate_and_update("hit_chance")


func set_base_evasion(value: float) -> void:
	base_evasion = value
	_recalculate_and_update("evasion")
