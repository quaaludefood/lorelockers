
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _last_moved_unit: Unit
var _active_unit_starting_position :=  Vector2.ZERO
var _walkable_cells := []
var _attack_mode:= false
var _target_unit: Unit

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _attack_overlay: AttackOverlay = $AttackOverlay
onready var _unit_path: UnitPath = $UnitPath
onready var _attack_path: AttackPath = $AttackPath
onready var _undobutton: Button = get_node("../../UserInterface/UndoButton")
onready var _attackbutton: Button = get_node("../../UserInterface/AttackButton")


func _ready() -> void:
	_reinitialize()
	_undobutton.connect("undo_pressed", self, "undo_move")
	_attackbutton.connect("attack_pressed", self, "scope_attack")
	_undobutton.disabled = true
	_attackbutton.disabled = true

func undo_move()-> void:	
	_units.erase(_last_moved_unit.cell)
	_last_moved_unit.position = _active_unit_starting_position
	_last_moved_unit.cell = grid.calculate_grid_coordinates(_active_unit_starting_position)
	_last_moved_unit.set_can_move(true)
	_units[_last_moved_unit.cell] = _last_moved_unit
	_attack_overlay.clear()
	_attack_path.clear()
	_attack_mode = false
	_undobutton.disabled = true

	

func scope_attack()-> void:
	_attack_mode = true
	var _max_range: int = 4
	var _range := []
	var _enemy_unit_cells := []
	var _friendly_unit_cells := []
	_range = _flood_fill(_last_moved_unit.cell, _max_range) 
	_attack_overlay.draw(_range)
	for unit in _units:
		_enemy_unit_cells.append(unit)
	_attack_path.initialize(_range, _enemy_unit_cells, _friendly_unit_cells, _last_moved_unit.cell)
	
func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	var array := []
	if unit.can_move:
		array = _flood_fill(unit.cell, unit.move_range)
	else: 
		_deselect_active_unit()
		_clear_active_unit()
	
	return array


## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.empty():
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				if _attack_mode == false:
					continue
			if coordinates in array:
				continue

			stack.append(coordinates)
	return array


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	_active_unit_starting_position = grid.calculate_map_position(_active_unit.cell)
	_last_moved_unit = _active_unit
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	yield(_active_unit, "walk_finished")	
	_clear_active_unit()
	_undobutton.disabled = false

## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return	
	if  _units[cell].deactivated == true:
		return
	if _attack_mode == true:
		_attack_path.target_selected = true
		_target_unit = _units[cell] 
		return
	_last_moved_unit = _units[cell]
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	
	if _active_unit.can_move:
		_walkable_cells = get_walkable_cells(_active_unit)
		_unit_overlay.draw(_walkable_cells)
		_unit_path.initialize(_walkable_cells)
		_undobutton.disabled = true
		_attackbutton.disabled = false
		
	else:
		scope_attack()

## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if _attack_path.target_selected == true && _attack_mode == true:	
		_last_moved_unit.set_deactivated(true)
		_attack_overlay.clear()
		_attack_path.stop()
		_attack_mode = false
		_undobutton.disabled = true
		_attackbutton.disabled = true
		_unit_path.initialize([])
		_play_attack()
	else:
		if not _active_unit:
			_select_unit(cell)
		elif _active_unit.is_selected:
			_move_active_unit(cell)


## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _attack_mode == true:
		_attack_path.draw(_last_moved_unit.cell, new_cell)
	elif _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)

func get_last_moved_unit() -> Unit:
	return _last_moved_unit
		
func _play_attack() -> void:
	var action_data: ActionData
	var _targets = []
	print("target unit: ", _target_unit)
	_targets.append(_target_unit)
	var action = AttackAction.new(action_data, _last_moved_unit, _targets)
	_last_moved_unit.act(action)
	yield(_active_unit, "action_finished")
	
	
	
	
	
	
	
	
	
	
