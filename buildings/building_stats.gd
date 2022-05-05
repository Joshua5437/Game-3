extends Resource
class_name BuildingStats

enum Type { Defense, Economic, Keep }

export(String) var name = ""
export(int) var health = 1
export(int) var price = 0
export(Type) var type
export(Array, String) var accepted_tiles = []

func get_repair_price():
	if type == Type.Keep:
		return price
	return price / 2 


func get_type_str():
	return "Building"