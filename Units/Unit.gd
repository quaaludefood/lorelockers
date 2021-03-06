## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished
signal action_finished
signal damage_taken(amount)
signal hit_missed

export var actions: Array
export var grid: Resource
export var skin: Texture setget set_skin
export var move_range := 6
export var skin_offset := Vector2.ZERO setget set_skin_offset
export var move_speed := 600.0
export var stats: Resource
export var ai_scene: PackedScene
export var profile_picture: Texture

var cell := Vector2.ZERO setget set_cell
var is_selected := false setget set_is_selected
var _is_walking := false setget _set_is_walking
var can_attack := true setget set_can_attack
var can_move := true setget set_can_move
var deactivated := false setget set_deactivated
var _ai_instance = null

onready var _sprite: Sprite = $PathFollow2D/Sprite
onready var _health_display: Label = $PathFollow2D/HealthDisplay
onready var _anim_player: AnimationPlayer = $AnimationPlayer
onready var _path_follow: PathFollow2D = $PathFollow2D

###Generic functions
func _ready() -> void:
	set_process(false)
	stats = stats.duplicate()
	stats.reinitialize()
	stats.connect("health_depleted", self, "_on_BattlerStats_health_depleted")	
		
	self.cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)
	_health_display.text = str(stats.health)
	if not Engine.editor_hint:
		curve = Curve2D.new()		

func _get_configuration_warning() -> String:
	var warning := ""
	if not stats:
		warning = "You need a UnitStats resource for this node to work."
	if not actions:
		warning = "You need an [Attack].tres resource for this node to work."
	if not profile_picture:
		warning = "You need to quick load a profile picture resource for this node to work."
	return warning

func setup(battlers: Array) -> void:
	if ai_scene:
		# We instance the `ai_scene` and store a reference to it.
		_ai_instance = ai_scene.instance()
		# `BattlerAI.setup()` takes the actor and all battlers in the encounter.
		_ai_instance.setup(self, battlers)
		# Adding the instance as a child to trigger its `_ready()` callback.
		add_child(_ai_instance)
		
func _process(delta: float) -> void:
	_path_follow.offset += move_speed * delta

	if _path_follow.offset >= curve.get_baked_length():
		self._is_walking = false
		_path_follow.offset = 0
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
		self.set_can_move(false)

###Getters and setters

func is_friendly() -> bool:
	return ai_scene == null
	
func is_fallen() -> bool:
	return stats.health == 0

func get_ai() -> Node:
	return _ai_instance

func set_cell(value: Vector2) -> void:
	cell = grid.clamp(value)


func set_is_selected(value: bool) -> void:
	is_selected = value
	if is_selected:
		_anim_player.play("selected")
	else:
		_anim_player.play("idle")

func set_can_move(value: bool) -> void:
	can_move = value
	
func set_can_attack(value: bool) -> void:
	can_attack = value

func set_deactivated(value: bool) -> void:
	if value == true:
		_anim_player.play("Deactivate")
		print(_anim_player)
		set_can_move(false)
		set_can_attack(false)
		set_is_selected(false)
	if value == false:
		_anim_player.play("idle")
		set_can_move(true)
		set_can_attack(true)
	
func set_skin(value: Texture) -> void:
	skin = value
	if not _sprite:
		yield(self, "ready")
	_sprite.texture = value


func set_skin_offset(value: Vector2) -> void:
	skin_offset = value
	if not _sprite:
		yield(self, "ready")
	_sprite.position = value


func _set_is_walking(value: bool) -> void:
	_is_walking = value
	set_process(_is_walking)
	
###Battle functions

func act(action) -> void:
	yield(action.apply_async(), "completed")
	emit_signal("action_finished")
	
func take_hit(hit: Hit) -> void:
	if hit.does_hit():
		_take_damage(hit.damage)
		emit_signal("damage_taken", hit.damage)
		
	else:
		emit_signal("hit_missed")
		
func _take_damage(amount: int) -> void:
	stats.health -= amount
	_health_display.text = str(stats.health)
		
	
func _on_BattlerStats_health_depleted() -> void:
	print(name, " fainted!")
	self.queue_free()
	
###Movement functions
		
	
func walk_along(path: PoolVector2Array) -> void:
	if path.empty():
		return
	if path[0].x > path[-1].x:
		_sprite.set_flip_h( true )
	else:
		_sprite.set_flip_h( false )
	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	self._is_walking = true

func flip_sprite(value: bool) -> void:
	_sprite.set_flip_h( value )
