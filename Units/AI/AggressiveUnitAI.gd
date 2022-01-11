class_name AggressiveBattlerAI
extends BattlerAI


func _choose_action(info: Dictionary) -> ActionData:
	print(info)
	return info.strongest_action


func _choose_targets(_action: ActionData, info: Dictionary) -> Array:
	# We always work with arrays of targets to support targeting multiple targets.
	# If you want to target only one opponent, don't forget to wrap it in an array.
	return [info.weakest_target]
