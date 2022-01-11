## Player-controlled cursor. Allows them to navigate the game grid, select units, and move them.
## Supports both keyboard and mouse (or touch) input.
tool
class_name Cursor
extends Node2D

## Emitted when clicking on the currently hovered cell or when pressing "ui_accept".
signal accept_pressed(cell)
## Emitted when the cursor moved to a new cell.
signal moved(new_cell)

## Grid resource, giving the node access to the grid size, and more.
export var grid: Resource
## Time before the cursor can move again in seconds.
export var ui_cooldown := 0.1

## Coordinates of the current cell the cursor is hovering.
var cell := Vector2.ZERO setget set_cell

onready var _timer: Timer = $Timer
onready var _main: Node = get_node("../../../Main")


func _ready() -> void:
	_timer.wait_time = ui_cooldown
	position = grid.calculate_map_position(cell)
	

func _unhandled_input(event: InputEvent) -> void:
	# Navigating cells with the mouse.
	if event is InputEventMouseMotion:
		self.cell = grid.calculate_grid_coordinates(_main.get_global_mouse_position())
	elif event.is_action_pressed("click"):
		emit_signal("accept_pressed", cell)
		get_tree().set_input_as_handled()

	var should_move := event.is_pressed() 
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()

	if not should_move:
		return


func _draw() -> void:
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.aliceblue, false, 2.0)


func set_cell(value: Vector2) -> void:
	if not grid.is_within_bounds(value):
		cell = grid.clamp(value)
	else:
		cell = value
	position = grid.calculate_map_position(cell)
	emit_signal("moved", cell)
	_timer.start()
