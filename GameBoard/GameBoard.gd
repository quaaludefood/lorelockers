
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
export var grid: Resource

var _units := {}
var _friendly_units := []
var _enemy_units := []
var _active_unit: Unit
var _last_moved_unit: Unit
var _active_unit_starting_position :=  Vector2.ZERO
var _walkable_cells := []
var _attack_mode:= false
var _target_unit: Unit
var _is_player_turn := false

onready var _unit_overlay: UnitOverlay = $UnitOverlay
onready var _attack_overlay: AttackOverlay = $AttackOverlay
onready var _unit_path: UnitPath = $UnitPath
onready var _attack_path: AttackPath = $AttackPath

onready var _attackbutton_1: Button = get_node("../UI/Interface/Attacks/AttackButton_1")
onready var _attackbutton_2: Button = get_node("../UI/Interface/Attacks/AttackButton_2")
onready var _attackbutton_3: Button = get_node("../UI/Interface/Attacks/AttackButton_3")
onready var _attackbuttoncontainer: HBoxContainer = get_node("../UI/Interface/Attacks")
onready var _endturnbutton: Button = get_node("../UI/Interface/Buttons/EndTurnButton")
onready var _undobutton: Button = get_node("../UI/Interface/Buttons/UndoButton")
onready var _profileimage: TextureRect = get_node("../UI/Interface/Profile/TextureRect/ProfileImage")

####Generic functions
func _ready() -> void:
	_reinitialize()
	_is_player_turn = true
	_endturnbutton.connect("endturn_pressed", self, "end_turn")
	_undobutton.connect("undo_pressed", self, "undo_move")
	_undobutton.disabled = true
	

	
func _reinitialize() -> void:
	_enemy_units.clear()
	_friendly_units.clear()
	_units.clear()
	var all_units = []
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		if unit.stats.health > 0: 
			all_units.append(unit)
			if unit.is_friendly():
				_friendly_units.append(unit)
			else:
				_enemy_units.append(unit)
	for button in _attackbuttoncontainer.get_children():
		button.visible = false
	for unit in all_units:
		_units[unit.cell] = unit
		unit.setup(all_units)
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("debug_info"):
		print("hi!")
		for unit in _units.values():
			print(unit.name, ": can move:", unit.can_move, " can attack:", unit.can_attack,
			  " is selected:", unit.is_selected, " deactivated:", unit.deactivated, 
			" is friendly:", unit.is_friendly())
	
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()
		
###Getters and setters

func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning

func is_occupied(cell: Vector2) -> bool:
	return true if _units.has(cell) else false

func get_last_moved_unit() -> Unit:
	return _last_moved_unit

func get_walkable_cells(unit: Unit) -> Array:
	var array := []
	if unit.can_move:
		array = _flood_fill(unit.cell, unit.move_range)
	else: 
		_deselect_active_unit()
		_clear_active_unit()	
	return array
	
###Turn functions

func end_turn()-> void:	
	_clear_attack_scoping()
	_clear_active_unit()
	_reinitialize()
	_profileimage.texture = load("res://Units/static.png")
	for unit in _units.values():
		unit.set_deactivated(false)	 
	_is_player_turn = not _is_player_turn
	if _is_player_turn == false:
		_play_ai_turn()

func _play_ai_turn() -> void:
	print(_enemy_units)
	for unit in _enemy_units:
		var t = Timer.new()
		t.set_wait_time(1)
		t.set_one_shot(true)
		self.add_child(t)
		t.start()
		yield(t, "timeout")
		_active_unit = unit
		_profileimage.texture = load(_active_unit.profile_picture.resource_path)
		print(_active_unit)
		var result: Dictionary = _active_unit.get_ai().choose()
		var action_data: ActionData
		var targets := []
		action_data = result.action
		targets = result.targets
		approach_enemy(unit, targets[0])
		if unit.position.x > targets[0].position.x:
			unit.flip_sprite(true)
		t.start()
		yield(t, "timeout")
		_play_attack(action_data, unit, targets[0])
		_reinitialize()


	
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return	
	if  _units[cell].deactivated == true:
		return
	if _attack_mode == true:
		_attack_path.target_selected = true
		return
	_last_moved_unit = _units[cell]
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_profileimage.texture = load(_active_unit.profile_picture.resource_path)
	display_attack_buttons()
	
	
	if _active_unit.can_move:
		_walkable_cells = get_walkable_cells(_active_unit)
		_unit_overlay.draw(_walkable_cells)
		_unit_path.initialize(_walkable_cells)
		_undobutton.disabled = true

	else:
		scope_attack(1)

func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

###Battle functions
func scope_attack(attack_number: int)-> void:
	print("selected attack number: ", attack_number )
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

func _play_attack(action_data: ActionData, unit: Unit, target: Unit ) -> void:
	action_data = unit.actions[0]
	var _targets = []
	_targets.append(target)	
	var action = AttackAction.new(action_data, unit, _targets)
	unit.act(action)
	yield(_last_moved_unit, "action_finished")
	unit.set_deactivated(true)
	_attack_mode = false
	_reinitialize()
	
func _clear_attack_scoping() -> void:	
	_attack_overlay.clear()
	_attack_path.stop()
	_undobutton.disabled = true
	_unit_path.initialize([])
			
###Movement functions
	
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

func approach_enemy(unit: Unit, enemy_unit: Unit) -> void:
	_walkable_cells = get_walkable_cells(unit)
	var enemy_location = enemy_unit.cell
	var distances = {}
	var result:Vector2
	for cell in _walkable_cells:
		distances[cell] = cell.distance_to(enemy_location)
	result = unit.cell
	for cell in distances.keys():
		if cell.distance_to(enemy_location) < result.distance_to(enemy_location):
			result = cell
	_move_active_unit(result)

func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		print("Is occupied:")
		return
	_active_unit_starting_position = grid.calculate_map_position(_active_unit.cell)
	_last_moved_unit = _active_unit
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	if _active_unit.is_friendly():
		_active_unit.walk_along(_unit_path.current_path)
		yield(_active_unit, "walk_finished")
	else:
		_active_unit.walk_along([_active_unit.cell, new_cell])
		yield(_active_unit, "walk_finished")
	_clear_active_unit()
	_undobutton.disabled = false



func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	print(_active_unit)
	print(_attackbutton_1)
	if _attack_path.target_selected == true && _attack_mode == true:
		_target_unit = _units[cell]
		var action_data: ActionData
		_play_attack(action_data, _last_moved_unit, _target_unit)
		_clear_attack_scoping()
	else:
		if not _active_unit:
			_select_unit(cell)
		elif _active_unit.is_selected:
			_move_active_unit(cell)


func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _attack_mode == true:
		_attack_path.draw(_last_moved_unit.cell, new_cell)
	elif _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)

func display_attack_buttons() -> void:
	if len(_active_unit.actions) > 0:
		_attackbutton_1.visible = true
		_attackbutton_1.get_node("Label").bbcode_text = "[center]" + _active_unit.actions[0].label + "[/center]"
		_attackbutton_1.connect("attack_pressed", self, "scope_attack")
	if len(_active_unit.actions) > 1:
		_attackbutton_2.visible = true
		_attackbutton_2.get_node("Label").bbcode_text = "[center]" +_active_unit.actions[1].label + "[/center]"
		_attackbutton_2.connect("attack_pressed", self, "scope_attack")
	if len(_active_unit.actions) > 2:
		_attackbutton_3.visible = true
		_attackbutton_3.get_node("Label").bbcode_text = "[center]" +_active_unit.actions[2].label + "[/center]"
		_attackbutton_3.connect("attack_pressed", self, "scope_attack")
	
	
