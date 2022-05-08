extends "res://buildings/building.gd"

func _ready():
	assert(stats is EconomicBuildingStats, "Economic building's stats should be EconomicBuildingStats!")
