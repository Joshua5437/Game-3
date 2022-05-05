extends Resource
class_name ConstructionStats

export(Resource) var stats
export(PackedScene) var scene

func _init(p_stats, p_scene):
	stats = p_stats
	scene = p_scene

func get_price():
	return stats.price
	
func get_damage():
	return stats.damage
	
func get_type():
	if stats.type == 0:
		return "Defense"
	if stats.type == 1:
		return "Economic"
	if stats.type == 2:
		return "Keep"
		
func get_gold():
	return stats.gold_production_amount
	
func get_name():
	if stats.name == 0:
		return "Farm"
	if stats.name == 1:
		return "Archer"
	if stats.name == 2:
		return "Mage"
	if stats.name == 3:
		return "Keep"
