## Draws the unit's movement path using an autotile.
class_name AttackPath
extends TileMap

export var grid: Resource

var _pathfinder: PathFinder
var _enemy_unit_locations:= []
var _friendly_unit_locations:= []
var _attacking_unit_location :=  Vector2.ZERO
var current_path := PoolVector2Array()


## Creates a new PathFinder that uses the AStar algorithm to find a path between two cells among
## the `walkable_cells`.
func initialize(walkable_cells: Array, enemy_unit_locations: Array, friendly_unit_locations: Array, attacking_unit_location: Vector2) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)
	_enemy_unit_locations = enemy_unit_locations
	_friendly_unit_locations = friendly_unit_locations
	_attacking_unit_location = attacking_unit_location
	self.modulate = Color(1, 1, 1, 0.3)

## Finds and draws the path between `cell_start` and `cell_end`
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	clear()
	self.modulate = Color(1, 1, 1,0.3)
	current_path = _pathfinder.calculate_point_path(cell_start, cell_end)
	if len(current_path) > 0:
		if current_path[-1] in _enemy_unit_locations and current_path[-1] != _attacking_unit_location:
			print("enemy detected!!!!!!!!")
			self.modulate = Color(1, 1, 1, 1)
		set_cellv(current_path[-1], 0)
		update_bitmask_region()


## Stops drawing, clearing the drawn path and the `_pathfinder`.
func stop() -> void:
	_pathfinder = null
	clear()
