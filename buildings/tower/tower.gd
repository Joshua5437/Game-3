extends "res://buildings/building.gd"

onready var range_area = $Range
onready var reload_timer = $ReloadTimer

export(PackedScene) var bullet

var tracked_enemies = []
var current_target : Node2D = null

func _process(delta):
	# Picks a target to shoot if the target does not exist
	if current_target == null and not tracked_enemies.empty():
		current_target = tracked_enemies[0]
	
	# Shoot at the target, if it exists
	if current_target != null and reload_timer.is_stopped() and not destroyed:
		shoot(current_target.position)
		reload_timer.start()

func get_weapon_range():
	return $Range/CollisionShape2D.shape.radius

# Shoots at the position
# target: target position
func shoot(target : Vector2):
	var new_bullet = bullet.instance()
	
	new_bullet.position = position
	new_bullet.target = target
	get_parent().add_child(new_bullet)

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

func _on_Range_body_entered(body):
	_add_enemy(body)

func _on_Range_body_exited(body):
	_remove_enemy(body)

func _on_Range_area_entered(area):
	_add_enemy(area)

func _on_Range_area_exited(area):
	_remove_enemy(area)
