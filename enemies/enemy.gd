extends KinematicBody2D

const THRESHOLD = 16

# Enemy navigation
var nav : Navigation2D = null
var path = []

# Movement
var velocity = Vector2.ZERO
var target = null # Where the enemy goes
var speed = 100

# Enemy attack
var attacking = false
var attack_damage = 1
onready var attack_timer = $AttackTimer

export var health = 3

func _ready():
	# Waits for other nodes to setup first
	yield(get_tree(), "idle_frame")
	
	# Get navigation node for navigation purposes
	if get_tree().has_group("navigation"):
		nav = get_tree().get_nodes_in_group("navigation")[0]

func _physics_process(delta):
	# Attacks the tower if the enemy is close
	if attacking and attack_timer.is_stopped() and target != null:
		attack_timer.start()
		target.damage(attack_damage)
	
	# Moves towards the tower to attack
	if not attacking:
		move_to_target()

func move_to_target():
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
		velocity = direction * speed
		velocity = move_and_slide(velocity) 

func generate_new_path():
	# Picks a tower to go to
	var towers = get_tree().get_nodes_in_group("towers")
	
	# Breaks if there are no towers to go to
	if towers.empty():
		return
	
	# Set the first tower as the target (should be replaced with something better)
	target = towers[0]
	
	# Get path to the tower
	path = nav.get_simple_path(global_position, target.global_position, false)

# Reduces the health based on amount of hits. Will queue free if 
# health reaches zero
func damage(hits):
	health -= hits
	if health <= 0:
		queue_free()

func _on_building_destruction():
	target = null

func _on_DamageArea_body_entered(body):
	if body == self:
		return
	
	if target == body:
		attacking = true

func _on_DamageArea_body_exited(body):
	if body == self:
		return
	
	if target == body:
		attacking = false
		target = null
