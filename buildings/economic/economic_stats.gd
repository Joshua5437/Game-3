extends "res://buildings/building_stats.gd"
class_name EconomicBuildingStats

export(int) var gold_production = 1


func get_type_str():
	return "Economic"
