class_name ActionData
extends Resource

export var label := "Base combat action"
# 
# The following properties help us filter potential targets on a battler's turn.
export var is_targeting_self := false
export var is_targeting_all := false

# Returns `true` if the `battler` has enough energy to use the action.
func can_be_used_by(battler) -> bool:
	return true 
