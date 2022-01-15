class_name AttackButton_3
extends Button

signal attack_pressed

func _on_AttackButton_3_button_up() -> void:
	emit_signal("attack_pressed", 3)
