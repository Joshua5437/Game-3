extends Node2D
class_name Building

signal keep_destroyed

const CELL_SIZE = 16

enum BuildingSize { _1x1, _2x2, _3x3 }

export(Resource) var stats
export(BuildingSize) var building_size = BuildingSize._1x1

var destroyed = false

func damage(hits):
	flash()
	stats.health -= hits
	if stats.health <= 0:
		die()

func die():
	destroyed = true
	$Sprite.modulate = Color.red
	if is_in_group("keep"):
		GlobalSignals.emit_signal("keep_destroyed")
	#queue_free()

func rebuild():
	destroyed = false
	$Sprite.modulate = Color.white

func get_grid_size():
	# Enums start at zero, so the size has to be offset by one
	var grid_size = building_size + 1
	return Vector2(grid_size, grid_size)

func _on_ClickArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game = get_tree().get_nodes_in_group("main")[0]
		var repair_price = stats.get_repair_price()
		var afford_repair = game.gold - repair_price >= 0
		if event.button_index == BUTTON_RIGHT and destroyed and afford_repair:
			game.gold -= repair_price
			rebuild()

func flash():
	$Sprite.material.set_shader_param("flash_modifer", 1.0)
	$FlashTimer.start()

func _on_FlashTimer_timeout():
	$Sprite.material.set_shader_param("flash_modifer", 0.0)
