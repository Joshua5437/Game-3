extends Camera2D

# Camera movement speed
export (float) var move_speed = 200.0

# Camera zoom bounds
export (Vector2) var camera_range = Vector2(0.5, 1.0)

#camera zoom code copied from https://www.gdquest.com/tutorial/godot/2d/camera-zoom/
# Lower cap for the `_zoom_level`.
export var min_zoom := 0.5
# Upper cap for the `_zoom_level`.
export var max_zoom := 1.0
# Controls how much we increase or decrease the `_zoom_level` on every turn of the scroll wheel.
export var zoom_factor := 0.1
# Duration of the zoom's tween animation.
export var zoom_duration := 0.2

# The camera's target zoom level.
var _zoom_level := 1.0 setget _set_zoom_level

# We store a reference to the scene's tween node.
onready var tween: Tween = $Tween
# Edge scroll boundary
export (bool) var edge_scroll_enabled = false
export (float) var edge_scroll_boundary = 12
export (float) var edge_scroll_speed = 100.0

# Boundaries for the camera
export (Vector2) var map_size = Vector2(64, 64)
export (int) var boundary_offset = 20

export (NodePath) var map_path
var map = null

var dragging = false
var mouse_start_pos = Vector2()
var screen_start_pos = Vector2()

onready var highlight_sprite = $Highlight

var current_construction = null
var weapon_range = 0

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
	
	# Update drawing if the player has construction selected
	if current_construction != null:
		update()


func _unhandled_input(event):
	if event.is_action_pressed("zoom_in"):
		# Inside a given class, we need to either write `self._zoom_level = ...` or explicitly
		# call the setter function to use it.
		_set_zoom_level(_zoom_level - zoom_factor)
	if event.is_action_pressed("zoom_out"):
		_set_zoom_level(_zoom_level + zoom_factor)


func _draw():
	# Zero out the weapon range if the current construction is not selected
	if current_construction == null:
		weapon_range = 0
	
	# Draws a circle arc
	draw_circle_arc(highlight_sprite.position, weapon_range, 0, 360, Color.green)


# Draws circle arc without filling in the circle
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	# Calculate all points on the circle arc
	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	# Draws the circle arc
	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)


# Moves the camera by using the movement keys
func _movement_by_keys(delta):
	# Fetch keyboard input as movement and normalizes it
	var move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var move_dir_normal = move_dir.normalized()
	
	# Determine the next position based on the movement input
	var movement = move_dir_normal * move_speed * delta
	position = get_camera_screen_center() + movement


# Moves the camera by using the mouse
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


# Moves the camera by having the cursor on the edge to move
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


# Handles signal when construction has been selected
func _on_mainUI_construction_selected(construction):
	# Assign the construction to the current construction
	current_construction = construction
	
	# Instance the building scene to fetch important values
	var building = construction.scene.instance()
	var sprite = building.get_node("Sprite")
	
	# Fetches the range of the weapon and queues draw request
	if building.has_method("get_weapon_range"):
		weapon_range = building.get_weapon_range()
	else:
		weapon_range = 0
	update()
	
	# Fill out the values for the highlight sprite
	highlight_sprite.texture = sprite.texture
	highlight_sprite.hframes = sprite.hframes
	highlight_sprite.vframes = sprite.vframes
	highlight_sprite.frame = sprite.frame
	
	# Grab the building stats
	var building_stats : BuildingStats = current_construction.stats

	# Make the building red if player's gold cannot pay for the building
	if (get_tree().current_scene.gold - building_stats.price >= 0) || building_stats.type == BuildingStats.Type.Keep:
		highlight_sprite.modulate = Color(1,1,1)
	else:
		highlight_sprite.modulate = Color(1,0,0)
	
	# Queue free the building instance
	building.queue_free()


func _on_MainScene_deselect_construction():
	current_construction = null
	highlight_sprite.texture = null
	
	# Zero the weapon range and queue a draw call
	weapon_range = 0
	update()


func _set_zoom_level(value: float) -> void:
	# We limit the value between `min_zoom` and `max_zoom`
	_zoom_level = clamp(value, min_zoom, max_zoom)
	# Then, we ask the tween node to animate the camera's `zoom` property from its current value
	# to the target zoom level.
	tween.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(_zoom_level, _zoom_level),
		zoom_duration,
		tween.TRANS_SINE,
		# Easing out means we start fast and slow down as we reach the target value.
		tween.EASE_OUT
	)
	tween.start()


func _on_MainScene_gold_updated(gold):
	if current_construction != null and (get_tree().current_scene.gold - current_construction.stats.price >= 0 or current_construction.stats.type == BuildingStats.Type.Keep):
		
		highlight_sprite.modulate = Color(1,1,1)
	else:
		highlight_sprite.modulate = Color(1,0,0)
