extends "res://scripts/game.gd"

export(PackedScene) var procedural_map

func setup():
	remove_child(map)
	map.queue_free()
	
	# Create procedural map
	map = procedural_map.instance()
	add_child(map)
	move_child(map, 0)
	
	map.generate_map()
	map.connect("placed_building", self, "_on_Map_building_placed")
	.setup()
