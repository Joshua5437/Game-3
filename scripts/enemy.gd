extends KinematicBody2D


#should convert these to correct casing
#old habits die hard
var currentPath: Array
var pathIndex: int
 
var speed:= 10.0
var velocity: Vector2

var target_loc : Vector2
var attack_range := 2.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#assumes that there is a direct one to corrspondence of map coordinates to world coordinates
#ie each tile has length 1
func _physics_process(delta):
	if (global_position.distance_to(target_loc) > attack_range):
		
		#really need to clean this code up
		#basically computes the speed in the correct direction to try and travel to
		velocity = (global_position.direction_to(currentPath[pathIndex]["vector"])) * speed * delta / currentPath[pathIndex]["weight"]
		#if you are going to overshoot clamp it
		#could definitely make this better
		if velocity.length_squared() > (global_position.distance_to(currentPath[pathIndex]["vector"])):
			velocity = (global_position.direction_to(currentPath[pathIndex]["vector"])) * global_position.distance_to(currentPath[pathIndex]["vector"])
		#move it
		move_and_slide(velocity, Vector2(0,0))
		
		
		if(global_position.is_equal_approx(currentPath[pathIndex]["vector"])):
			
			pathIndex+=1

func set_path(new_path: Array):
	currentPath = new_path
	pathIndex = 1;
