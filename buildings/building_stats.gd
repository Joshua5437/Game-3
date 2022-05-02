extends Resource
class_name BuildingStats

enum Type { Defense, Economic, Keep }

enum Name { Farm, Archer, Mage, Keep }

export(int) var health
export(int) var price # How much to place a building down
export(int) var damage
export(Type) var type
export(Name) var name
export(int) var gold_production_amount 

func get_repair_price():
	if type == Type.Keep:
		return price
	return price / 2 
