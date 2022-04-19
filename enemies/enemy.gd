extends KinematicBody2D

var nav : Navigation2D = null
var path = []
var threshold = 16
var velocity = Vector2.ZERO
var speed = 100

func _ready():
	yield(get_tree(), "idle_frame")
	
	if get_tree().has_group("navigation"):
		nav = get_tree().get_nodes_in_group("navigation")[0]

func _physics_process(delta):
	move_to_target()

func move_to_target():
	if path.empty():
		generate_new_path()
		return
	
	if global_position.distance_to(path[0]) < threshold:
		path.remove(0)
	else:
		var direction = global_position.direction_to(path[0])
		velocity = direction * speed
		velocity = move_and_slide(velocity) 

func generate_new_path():
	# Picks a tower to go to
	var towers = get_tree().get_nodes_in_group("towers")
	if towers.empty():
		return
	
	path = nav.get_simple_path(global_position, towers[0].global_position)
