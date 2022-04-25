extends Resource
class_name BuildingStats

enum Type { Defense, Economic, Keep }

export(int) var health
export(int) var price # How much to place a building down
export(int) var damage
export(Type) var type

func get_repair_price():
	if type == Type.Keep:
		return price
	return price / 2 

func is_keep():
	return type == Type.Keep
