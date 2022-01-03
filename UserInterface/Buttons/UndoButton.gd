class_name UndoButton
extends Button


signal undo_pressed


func _on_UndoButton_button_up() -> void:
	emit_signal("undo_pressed")
