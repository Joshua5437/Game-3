extends "res://buildings/building.gd"
# TODOs:
# - Needs better texture for all

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
	if current_target != null and reload_timer.is_stopped():
		shoot(current_target.position)
		reload_timer.start()

# Shoots at the position
# target: target position
func shoot(target : Vector2):
	var new_bullet = bullet.instance()
	
	new_bullet.position = position
	new_bullet.direction = global_position.direction_to(target)
	get_parent().add_child(new_bullet)

func _on_Range_body_entered(body):
	# Adds enemy to list of tracked enemies
	if body.is_in_group("enemies"):
		tracked_enemies.push_back(body)
		current_target = body

func _on_Range_body_exited(body):
	# Removes enemy from list of track enemies
	if body.is_in_group("enemies"):
		current_target = null
		tracked_enemies.erase(body)
