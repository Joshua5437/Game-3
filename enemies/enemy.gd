extends Actor
class_name Enemy

const THRESHOLD = 8
const BUILDINGS_GROUP = "buildings"

enum DamageType { Melee, Ranged, Mixed }

# Enemy stats
export var speed = 100
export var damage_amount = 1
export var building_weights = {}

onready var attack_timer = $AttackTimer

var map = null
var target = null
var in_range = false
var path = []

func _ready():
	$HealthBar.max_value = health
	$HealthBar.value = health

# Setups variables with the Enemy class
func setup(p_map):
	map = p_map
	map.connect("pathfinding_changed", self, "generate_path")


# Processes during game time
func _process(delta):
	if target == null:
		pick_target()
	move_towards_target(delta)

	if is_attack_ready():
		damage_target()


func _physics_process(_delta):
	if target == null:
		return
	var areas = $Range.get_overlapping_areas()
	if target in areas:
		in_range = true
	


# Moves towards the target if not in range
func move_towards_target(delta):
	if target == null or in_range:
		return
	if path.empty():
		generate_path()
	
	# Double check if they do not have a path
	if path.empty():
		print("Cannot pathfind")
		return
	
	if global_position.distance_to(path[0]) < THRESHOLD:
		# Removes path node if the enemy is close enough
		path.remove(0)
	else:
		# Enemy moves towards the one of the path points
		var direction = global_position.direction_to(path[0])
		#look_at(path[0])
		#if we want speed to be affected by the terrain
		var velocity = direction * (speed * map.get_cell_speed_modifier(global_position))
		#otherwise
		#velocity = direction * enemy_type.speed
		#velocity = move_and_slide(velocity) 
		position += velocity * delta


# Damages the target if in range
func damage_target():
	target.take_damage(damage_amount)
	attack_timer.start()


# Returns whether attacking the target is ready or not
func is_attack_ready():
	return target != null and in_range and attack_timer.is_stopped()


# Overrides Actor's take_damage function
func take_damage(amount):
	$AnimationPlayer.play("TakeDamage")
	.take_damage(amount)
	$HealthBar.value = health
	if is_dead():
		$AnimationPlayer.play("Die")


# Picks a target
func pick_target(override=false):
	if target != null and not override:
		return
	target = null
	in_range = false

	var all_buildings = get_tree().get_nodes_in_group(BUILDINGS_GROUP)
	if all_buildings.empty():
		return

	var building_values = []
	
	for i in range(len(all_buildings)):
		if all_buildings[i].is_dead():
			continue

		var target_value = global_position.distance_to(all_buildings[i].global_position)
		
		var building_group = all_buildings[i].get_groups()
		for key in building_weights:
			if key in building_group:
				target_value -= float(building_weights[key])
		
		building_values.append([target_value, i])
	
	if building_values.empty():
		return
	
	building_values.sort_custom(self, "target_sort")
	
	for valuable_building in building_values:
		target = all_buildings[valuable_building[1]]
		generate_path()
		if not path.empty():
			break
	target.connect("die", self, "_on_Actor_death")


# Generates path for the enemy to move through
func generate_path():
	if target == null:
		return
	
	path = map.get_path_to_point(global_position, target.global_position)


# Handle any targets
func _on_Range_area_entered(area:Area2D):
	if area.is_in_group(BUILDINGS_GROUP) and area == target:
		in_range = true


# Generate a new target if actor is dead
func _on_Actor_death(area:Actor):
	pick_target(true)


# Custom ascending sorting for picking targets
static func target_sort(a, b):
	return a[0] < b[0]
