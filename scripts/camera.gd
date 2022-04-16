extends Camera2D
# TODOs
# - Add a camera movement using the mouse middle button (drag and move movement)

# Camera movement speed
export (float) var move_speed = 100.0

# Boundaries for the camera
export (Vector2) var map_size = Vector2(64, 64)
export (int) var boundary_offset = 1

func _ready():
	# Establishes boundaries where the camera can move
	var new_boundary = boundary_offset * 16
	limit_top = -new_boundary
	limit_left = -new_boundary
	limit_right = map_size.x * 16 + new_boundary
	limit_bottom = map_size.y * 16 + new_boundary

func _process(delta):
	# Fetch keyboard input as movement and normalizes it
	var move_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var move_dir_normal = move_dir.normalized()
	
	# Determine the next position based on the movement input
	var movement = move_dir_normal * move_speed * delta
	position = get_camera_screen_center() + movement
