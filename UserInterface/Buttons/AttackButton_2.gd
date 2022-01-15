class_name AttackButton_2
extends Button

signal attack_pressed

func _on_AttackButton_2_button_up() -> void:
	emit_signal("attack_pressed", 2)
