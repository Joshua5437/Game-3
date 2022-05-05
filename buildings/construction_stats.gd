extends Resource
class_name ConstructionStats

export(Resource) var stats
export(PackedScene) var scene

func _init(p_stats, p_scene):
	stats = p_stats
	scene = p_scene
