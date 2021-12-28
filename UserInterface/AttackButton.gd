class_name AttackButton
extends Button

onready var rootnode: Node2D = get_tree().root.get_child(0)
onready var gameboard: GameBoard = rootnode.get_node("UserInterface/GameBoard")


signal attack_pressed


func _on_AttackButton_button_up() -> void:
	var unit = gameboard.get_last_moved_unit()
	emit_signal("attack_pressed")

