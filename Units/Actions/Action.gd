
class_name Action
extends Reference

# Emitted when the action finished playing.
signal finished

var _data : ActionData
var _actor
var _targets := []


func _init(data: ActionData, actor, targets: Array) -> void:
	_data = data
	_actor = actor
	_targets = targets


# Applies the action on `_targets` using `_actor`'s stats.
func apply_async() -> bool:
	return _apply_async()

func _apply_async() -> bool:
	emit_signal("finished")
	return true

func targets_opponents() -> bool:
	return true
