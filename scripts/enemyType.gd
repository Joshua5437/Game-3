extends Object
class_name EnemyType

var name: String
var max_health: int
var speed: int
var attack_range: int
var attack_amount: int
var attack_delay: float

#to be implemented, not sure how we want  to do this
var building_type_targets := []
func _init(name, max_health, speed, attack_range, attack_amount):
	self.name = name
	self.speed = speed
	self.attack_range = attack_range
	self.attack_amount = attack_amount
	
	
