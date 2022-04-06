extends KinematicBody2D

class_name Enemy
#should convert these to correct casing
#old habits die hard
var currentPath: Array
var pathIndex: int
 

var velocity: Vector2

var target_loc : Vector2
var attack_timer: float

var enemy_type : EnemyType
# Called when the node enters the scene tree for the first time.

func setup(enemy_type, first_loc: Vector2, first_path: Array):
	self.enemy_type = enemy_type
	self.target_loc = first_loc
	self.currentPath = first_path
	pathIndex = 0
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#assumes that there is a direct one to corrspondence of map coordinates to world coordinates
#ie each tile has length 1
#could make them actual physics objects that push against each other
#probably need to test if so, might be strange
func _physics_process(delta):
	if (global_position.distance_to(target_loc) > enemy_type.attack_range):
		move(delta)
		attack_timer = 0
	else:
		if (attack_timer == 0):
			attack()
			attack_timer = enemy_type.attack_delay
		else:
			attack_timer -= delta
			
		
func move(delta):
	#really need to clean this code up
	#basically computes the speed in the correct direction to try and travel to
	velocity = (global_position.direction_to(currentPath[pathIndex]["vector"])) * enemy_type.speed * delta / currentPath[pathIndex]["weight"]
	#if you are going to overshoot clamp it
	#could definitely make this better
	if velocity.length_squared() > (global_position.distance_to(currentPath[pathIndex]["vector"])):
		velocity = (global_position.direction_to(currentPath[pathIndex]["vector"])) * global_position.distance_to(currentPath[pathIndex]["vector"])
	#move it
	move_and_slide(velocity, Vector2(0,0))
	
	
	if(global_position.is_equal_approx(currentPath[pathIndex]["vector"])):
		
		pathIndex+=1
		
#add actual functionality later
func attack():
	pass
func set_path(new_path: Array):
	currentPath = new_path
	pathIndex = 0;
