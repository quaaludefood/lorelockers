class_name AttackButton
extends Button

onready var rootnode: Node2D = get_tree().root.get_child(0)
onready var gameboard: GameBoard = rootnode.get_node("UserInterface/GameBoard")

#func _on_Button_button_up() -> void:
#	print(gameboard)		
#	for object in gameboard.get_children():
#		if object.is_class("Path2D"):
#			object.set_can_attack(true)
#			object.set_can_move(true)
#


func _on_AttackButton_button_up() -> void:
	print("Attack pressed!")
	var unit = gameboard.get_last_moved_unit()
	print(unit)

