extends "res://buildings/building.gd"

onready var range_area = $Range
onready var reload_timer = $ReloadTimer

export(PackedScene) var bullet

var tracked_enemies = []
var current_target : Node2D = null
var show_range = false

func _process(delta):
	# Picks a target to shoot if the target does not exist
	if current_target == null and not tracked_enemies.empty():
		current_target = tracked_enemies[0]
	
	# Shoot at the target, if it exists
	if current_target != null and reload_timer.is_stopped() and not destroyed:
		shoot(current_target.position)
		reload_timer.start()


func _draw():
	if show_range:
		# Center has to be local to the position of the tower
		draw_circle_arc(Vector2(0,0), get_weapon_range(), 0, 360, Color.green)


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


func get_weapon_range():
	return $Range/CollisionShape2D.shape.radius


# Shoots at the position
# target: target position
func shoot(target : Vector2):
	var new_bullet = bullet.instance()
	
	new_bullet.position = position
	new_bullet.target = target
	get_parent().add_child(new_bullet)
	$ShootSound.play()

# Adds enemy to list of tracked enemies
func _add_enemy(enemy : Node2D):
	if not enemy.is_in_group("enemies"):
		return
	
	tracked_enemies.push_back(enemy)
	current_target = enemy

# Removes enemy from list of track enemies
func _remove_enemy(enemy : Node2D):
	if not enemy.is_in_group("enemies"):
		return
	
	current_target = null
	tracked_enemies.erase(enemy)
	
	# Check if there is any enemy to kill
	if not tracked_enemies.empty():
		current_target = tracked_enemies[0]

func _on_Range_area_entered(area):
	_add_enemy(area)

func _on_Range_area_exited(area):
	_remove_enemy(area)


func _on_Tower_mouse_entered():
	show_range = true
	update()


func _on_Tower_mouse_exited():
	show_range = false
	update()
