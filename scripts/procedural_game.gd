extends "res://scripts/game.gd"

export(PackedScene) var procedural_map

func setup():
	map.generate_map()
	.setup()
