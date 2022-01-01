#Is a command
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

# Applies the action on the targets, using the actor's stats.
# Returns `true` if the action succeeded.
func apply_async() -> bool:
	return _apply_async()


# Notice that the function's name includes the suffix "async".
# This indicates the function should be a coroutine. That's because in our case,
# finishing an action involves animation.
func _apply_async() -> bool:
	# In the abstract base Action class, we don't do anything!
	emit_signal("finished")
	return true
