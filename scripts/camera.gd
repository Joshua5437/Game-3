extends Camera2D

# Camera movement speed
export (float) var move_speed = 200.0

# Camera zoom bounds
export (Vector2) var camera_range = Vector2(0.5, 1.0)

# Edge scroll boundary
export (bool) var edge_scroll_enabled = false
export (float) var edge_scroll_boundary = 12
export (float) var edge_scroll_speed = 100.0

# Boundaries for the camera
export (Vector2) var map_size = Vector2(64, 64)
export (int) var boundary_offset = 1

export (NodePath) var map_path
var map = null

var dragging = false
var mouse_start_pos = Vector2()
var screen_start_pos = Vector2()

onready var highlight_sprite = $Highlight

func _ready():
	# Establishes boundaries where the camera can move
	var new_boundary = boundary_offset * 16
	limit_top = -new_boundary
	limit_left = -new_boundary
	limit_right = map_size.x * 16 + new_boundary
	limit_bottom = map_size.y * 16 + new_boundary
	
	map = get_node(map_path)

func _input(event):
	_movement_by_middle_mouse_button(event)

func _process(delta):
	_movement_by_keys(delta)
	_movement_by_edge_scroll(delta)
	
	var global_mouse_pos = get_global_mouse_position()
	var new_highlight_pos = map.get_grid_center_position(global_mouse_pos)
	highlight_sprite.global_position = new_highlight_pos

func _movement_by_keys(delta):
	# Fetch keyboard input as movement and normalizes it
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir_normal = move_dir.normalized()
	
	# Determine the next position based on the movement input
	var movement = move_dir_normal * move_speed * delta
	position = get_camera_screen_center() + movement

func _movement_by_middle_mouse_button(event):
	# Player clicks on the middle mouse button to drag the camera around
	if event is InputEventMouseButton:
		if event.is_pressed() and event.button_index == BUTTON_MIDDLE:
			mouse_start_pos = event.position
			screen_start_pos = get_camera_screen_center()
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = zoom * (mouse_start_pos - event.position) + screen_start_pos

func _movement_by_edge_scroll(delta):
	if not edge_scroll_enabled:
		return
	
	# Determine if the cursor is in the boundary and find the direction
	var mouse_pos = get_viewport().get_mouse_position()
	var screen_size = get_viewport().size
	var delta_speed = edge_scroll_speed * delta
	
	if mouse_pos.x <= edge_scroll_boundary:
		position += Vector2.LEFT * delta_speed
	elif mouse_pos.x >= screen_size.x - edge_scroll_boundary:
		position += Vector2.RIGHT * delta_speed
	
	if mouse_pos.y <= edge_scroll_boundary:
		position += Vector2.UP * delta_speed
	elif mouse_pos.y >= screen_size.y - edge_scroll_boundary:
		position += Vector2.DOWN * delta_speed
