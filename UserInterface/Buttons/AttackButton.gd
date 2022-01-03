class_name AttackButton
extends Button


signal attack_pressed


func _on_AttackButton_button_up() -> void:
	emit_signal("attack_pressed")
