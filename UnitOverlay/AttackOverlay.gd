## Draws a selected unit's walkable tiles.
class_name AttackOverlay
extends TileMap


## Fills the tilemap with the cells, giving a visual representation of the cells a unit can walk.
func draw(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cellv(cell, 0)
