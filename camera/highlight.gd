extends Sprite

const CELL_SIZE = 16

var current_construction : ConstructionStats = null
var weapon_range = 0

onready var tile_map = TileMap.new()


func _ready():
	tile_map.cell_size = Vector2(16, 16)


func update_position():
	var new_position = get_global_mouse_position()
	#global_mouse_position.x = stepify(global_mouse_position.x, CELL_SIZE)
	#global_mouse_position.y = stepify(global_mouse_position.y, CELL_SIZE)
	
	new_position = tile_map.world_to_map(new_position)
	new_position = tile_map.map_to_world(new_position)
	new_position += Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	
	global_position = new_position
	update()


func _draw():
	# Zero out the weapon range if the current construction is not selected
	if current_construction == null:
		weapon_range = 0
	
	# Draws a circle arc
	draw_circle_arc(Vector2(0, 0), weapon_range, 0, 360, Color.green)


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


func select_construction(construction : ConstructionStats):
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
	texture = sprite.texture
	hframes = sprite.hframes
	vframes = sprite.vframes
	frame = sprite.frame
	
	# Show the sprite now
	show()
	
	# Grab the building stats
	var building_stats : BuildingStats = current_construction.stats

	# Make the building red if player's gold cannot pay for the building
	check_gold_price(get_tree().current_scene.gold)
	
	# Queue free the building instance
	building.queue_free()


func deselect_construction():
	# Hide the sprite
	hide()
	
	# Zero the weapon range and queue a draw call
	weapon_range = 0
	update()


func check_gold_price(gold):
	if current_construction == null:
		return
	var stats = current_construction.stats
	
	if gold - stats.price >= 0 or stats.type == BuildingStats.Type.Keep:
		modulate = Color(1,1,1)
	else:
		modulate = Color(1,0,0)
