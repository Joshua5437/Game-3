extends "res://buildings/building_stats.gd"
class_name DefenseBuildingStats

export(int) var damage = 1


func get_type_str():
	return "Defense"