extends Area2D
# TODO: Fix the target system where it should go to the next tower assuming
# the next tower is next to the target that was destroyed

const THRESHOLD = 16
const MAX_INT = 9223372036854775807
# Enemy navigation
var map = null
var path = []

# Movement
var velocity = Vector2.ZERO
var target = null # Where the enemy goes

# Enemy attack
var attacking = false
onready var attack_timer = $AttackTimer

var health : int
var dead = false

export(Resource) var enemy_type

signal die(enemy)

func _ready():
	
	#sets up the enemytype
	#TODO: change how this is set
	
	#now handled by set_enemy_type
	#enemy_type = EnemyType.new("Skeleton", 3, 100, 1, 1, .5, [{"name": "towers", "weight": 1}])
	health = enemy_type.max_health
	attack_timer.wait_time = enemy_type.attack_delay
	# Waits for other nodes to setup first
	# Commented because of the wave system
	#yield(get_tree(), "idle_frame")
	
	# Get navigation node for navigation purposes
	
	map = get_tree().get_nodes_in_group("Map")[0]
	map.connect("pathfinding_changed", self, "_on_pathfinding_changed")
	
func set_enemy_type(new_enemy_type):
	enemy_type = new_enemy_type
	#i would really like to set what is below here, 
	#but attacktimer may not be initialized yet apparently
	#health = enemy_type.max_health
	#attack_timer.wait_time = enemy_type.attack_delay
func _process(delta):
	# Attacks the tower if the enemy is close
	if attacking and attack_timer.is_stopped() and target != null:
		attack_timer.start()
		target.damage(enemy_type.attack_amount)
	
	# Picks a new target if target is destroyed
	if target != null and target.destroyed:
		attacking = false
		pick_target()
	
	# Moves towards the tower to attack
	if not attacking:
		move_to_target(delta)

func move_to_target(delta):
	# Generates a path if current path is already empty
	if path.empty():
		generate_new_path()
		return
	
	if global_position.distance_to(path[0]) < THRESHOLD:
		# Removes path node if the enemy is close enough
		path.remove(0)
	else:
		# Enemy moves towards the one of the path points
		var direction = global_position.direction_to(path[0])
		#if we want speed to be affected by the terrain
		velocity = direction * (enemy_type.speed / map.get_cell_weight(global_position))
		#otherwise
		#velocity = direction * enemy_type.speed
		#velocity = move_and_slide(velocity) 
		position += velocity * delta

func pick_target():
	var towers = []
	var tower_weights = []
	for tower_type in enemy_type.towers_to_target:
		var towers_to_add = get_tree().get_nodes_in_group(tower_type["name"])
		#print(tower_type["name"])
		towers += towers_to_add
		#print(towers)
		for i in range(towers_to_add.size()):
			tower_weights.append(tower_type["weight"])
		
	#make sure that all enemies eventually target keep if they run out of other towers
	#if (towers.size()== 0):
	var towers_to_add = get_tree().get_nodes_in_group("keep")
	towers += towers_to_add
	for i in range(towers_to_add.size()):
		#add a ridiculously high weight that basically guarantees that this will only be chosen if there are no other options.
		tower_weights.append(MAX_INT/2)
		
	if towers.size() == 0:
		target = null
		return
	# Reset target and path
	target = null
	path = []
	var current_tower_weight = MAX_INT
	for i in range(towers.size()):
		#simply use raw distance for adding to the weight (arguably should switch to polling the astar cost)
		var new_weight = tower_weights[i] + global_position.distance_squared_to(towers[i].global_position)
		if not towers[i].destroyed and new_weight < current_tower_weight:
			target = towers[i]
			current_tower_weight = new_weight
			

func generate_new_path():
	# Picks a target
	pick_target()
	
	# Will not generate path since target is empty
	if target == null:
		return
	
	# Get path to the tower
	
	path = map.get_path_to_point(global_position, target.global_position)

# Reduces the health based on amount of hits. Will queue free if 
# health reaches zero
func damage(hits):
	health -= hits
	if health <= 0 and not dead:
		dead = true
		emit_signal("die", self)
		queue_free()

func _on_building_destruction():
	target.disconnect("destroyed", self, "_on_building_destruction")
	attacking = false
	target = null
	generate_new_path()

func _on_pathfinding_changed():
	generate_new_path()

func _on_DamageArea_area_entered(area):
	if area == self:
		return
	
	if target == area:
		target.connect("destroyed", self, "_on_building_destruction")
		attacking = true

func _on_DamageArea_area_exited(area):
	if area == self:
		return
	
	if target == area:
		target.disconnect("destroyed", self, "_on_building_destruction")
		attacking = false
		target = null
