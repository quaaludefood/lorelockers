class_name AttackButton
extends Button

signal has_attacked

func _ready()-> void:
	self.visible = false
	


func _on_AttackButton_button_up() -> void:
	print("Clicked!")
	emit_signal("has_attacked")
	



func _on_Unit_walk_finished() -> void:
	print("walk finished!")
	self.visible = true
