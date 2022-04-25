extends Resource
class_name EnemyType

export (String) var name: String setget ,get_name
export (int) var max_health: int setget ,get_max_health
export (int) var speed: int setget ,get_speed
export (int) var attack_range: int setget ,get_attack_range
export (int) var attack_amount: int setget ,get_attack_amount
export (float) var attack_delay: float setget ,get_attack_delay
export (Array, Dictionary) var towers_to_target: Array setget, get_towers_to_target


func _init(name = "default", max_health = 1, speed = 100, attack_range = 16, attack_amount = 1, attack_delay = 1, towers_to_target = []):
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
