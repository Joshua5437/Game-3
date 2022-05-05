extends Node2D
class_name Building

signal destroyed

const CELL_SIZE = 16

enum BuildingSize { _1x1, _2x2, _3x3 }

export(Resource) var stats
export(BuildingSize) var building_size = BuildingSize._1x1

# Tracks whether the building is destroyed or not
var destroyed = false

# Store starting health first
onready var health = stats.health

func damage(hits):
	flash()
	health -= hits
	if health <= 0:
		die()

func die():
	destroyed = true
	$Sprite.modulate = Color.red
	if is_in_group("keep"):
		GlobalSignals.emit_signal("keep_destroyed")
	emit_signal("destroyed")

func rebuild():
	destroyed = false
	$Sprite.modulate = Color.white
	health = stats.health

func get_grid_size():
	# Enums start at zero, so the size has to be offset by one
	var grid_size = building_size + 1
	return Vector2(grid_size, grid_size)

func _on_Building_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	# Repairs a damaged building by pressing repair action
	if destroyed and event.is_action_pressed("repair"):
		var game = get_tree().get_nodes_in_group("main")[0]
		var repair_price = stats.get_repair_price()
		var afford_repair = game.gold - repair_price >= 0
		
		if destroyed and afford_repair:
			game.gold -= repair_price
			rebuild()


# Flashes the building using shader and starts the countdown
func flash():
	$Sprite.material.set_shader_param("flash_modifer", 1.0)
	$FlashTimer.start()


# Timeout function for flashing, and when it timeouts, the flash disappears
func _on_FlashTimer_timeout():
	$Sprite.material.set_shader_param("flash_modifer", 0.0)
