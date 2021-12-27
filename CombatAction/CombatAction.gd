
class_name CombatAction
extends Node

onready var rootnode: Node2D = get_tree().root.get_child(0)
#onready var gameboard: GameBoard = rootnode.get_node("GameBoard")

var _friendly_units := []
var _enemy_units := []


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#		for object in gameboard.get_children():
#			if object.is_class("Path2D"):
#				if object.is_friendly:
#					_friendly_units.append(object)
#				else:
#					_enemy_units.append(object)

	#print("Number of friendly units: ", len(_friendly_units))

