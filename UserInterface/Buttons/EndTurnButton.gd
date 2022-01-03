class_name EndTurnButton
extends Button

signal endturn_pressed


func _on_EndTurnButton_button_up() -> void:
	emit_signal("endturn_pressed")
