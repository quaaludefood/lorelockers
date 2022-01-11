class_name BattlerAI
extends Node

enum HealthStatus { CRITICAL, LOW, MEDIUM, HIGH, FULL }

var _next_actions := []
var _rng := RandomNumberGenerator.new()

var _actor: Unit
var _party := []
var _opponents := []


func setup(actor: Unit, battlers: Array) -> void:
	_actor = actor
	for battler in battlers:
		var is_opponent: bool = battler.is_friendly() != actor.is_friendly()
		if is_opponent:
			_opponents.append(battler)
		else:
			_party.append(battler)


func choose() -> Dictionary:
	assert(
		not _opponents.empty(),
		"You must call setup() on the AI and give it opponents for it to work."
	)
	return _choose()


# @tags: virtual
func _choose() -> Dictionary:
	var battle_info := _gather_information()
	var action: ActionData
	var targets := []

	if not _next_actions.empty():
		action = _next_actions.pop_front()
	else:
		action = _choose_action(battle_info)

	if action.is_targeting_self:
		targets = [_actor]
	else:
		targets = _choose_targets(action, battle_info)
	return {action = action, targets = targets}


# @tags: virtual
func _choose_action(_info: Dictionary) -> ActionData:
	return _actor.actions[0]


# @tags: virtual
func _choose_targets(_action: ActionData, _info: Dictionary) -> Array:
	return [_info.weakest_target]


func _gather_information() -> Dictionary:
	var actions := _get_available_actions()
	var attack_actions := _get_attack_actions_from(actions)
	var defensive_actions := _get_defensive_actions_from(actions)
	var info := {
		weakest_target = _get_battler_with_lowest_health(_opponents),
		weakest_ally = _get_battler_with_lowest_health(_party),
		health_status = _get_health_status(_actor),
		fallen_party_count = _count_fallen_party(),
		fallen_opponents_count = _count_fallen_opponents(),
		available_actions = actions,
		attack_actions = attack_actions,
		defensive_actions = defensive_actions,
		strongest_action = _find_most_damaging_action_from(attack_actions),
	}
	return info


func _get_battler_with_lowest_health(battlers: Array) -> Unit:
	var weakest: Unit = battlers[0]
	for battler in battlers:
		if battler.stats.health < weakest.stats.health:
			weakest = battler
	return weakest


func _count_fallen_party() -> int:
	var count := 0
	for ally in _party:
		if ally.is_fallen():
			count += 1
	return count


func _count_fallen_opponents() -> int:
	var count := 0
	for opponent in _opponents:
		if opponent.is_fallen():
			count += 1
	return count


func _get_health_status(battler: Unit) -> int:
	if _is_health_below(battler, 0.1):
		return HealthStatus.CRITICAL
	elif _is_health_below(battler, 0.3):
		return HealthStatus.LOW
	elif _is_health_below(battler, 0.6):
		return HealthStatus.MEDIUM
	elif _is_health_below(battler, 1.0):
		return HealthStatus.HIGH
	else:
		return HealthStatus.FULL


func _is_health_below(battler: Unit, rate: float) -> bool:
	rate = clamp(rate, 0.0, 1.0)
	return battler.stats.health < battler.stats.health * rate


func _is_health_above(battler: Unit, rate: float) -> bool:
	rate = clamp(rate, 0.0, 1.0)
	return battler.stats.health > battler.stats.health * rate


func _get_available_actions() -> Array:
	var actions := []
	for action in _actor.actions:
		if action.can_be_used_by(_actor):
			actions.append(action)
	return actions


func _get_attack_actions_from(available_actions: Array) -> Array:
	var attack_actions := []
	for action in available_actions:
		if action is AttackActionData:
			attack_actions.append(action)
	return attack_actions


func _get_defensive_actions_from(available_actions: Array) -> Array:
	var defensive_actions := []
	for action in available_actions:
		if not action is AttackActionData:
			defensive_actions.append(action)
	return defensive_actions


func _find_most_damaging_action_from(attack_actions: Array):
	var strongest_action
	var highest_damage := 0
	for action in attack_actions:
		var total_damage = action.calculate_potential_damage_for(_actor)
		if total_damage > highest_damage:
			strongest_action = action
			highest_damage = total_damage
	return strongest_action
