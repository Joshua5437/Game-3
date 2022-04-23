extends Object
class_name EnemyType

var name: String setget ,get_name
var max_health: int setget ,get_max_health
var speed: int setget ,get_speed
var attack_range: int setget ,get_attack_range
var attack_amount: int setget ,get_attack_amount
var attack_delay: float setget ,get_attack_delay
var towers_to_target: Array setget, get_towers_to_target

#to be implemented, not sure how we want  to do this
var building_type_targets := []
func _init(name, max_health, speed, attack_range, attack_amount, attack_delay, towers_to_target):
	self.name = name
	self.max_health = max_health
	self.speed = speed
	self.attack_range = attack_range
	self.attack_amount = attack_amount
	self.attack_delay = attack_delay
	self.towers_to_target = towers_to_target
	

func get_name():
	return name
func get_max_health():
	return max_health

func get_speed():
	return speed
	
func get_attack_range():
	return attack_range

func get_attack_amount():
	return attack_amount
	
func get_attack_delay():
	return attack_delay

func get_towers_to_target():
	return towers_to_target
