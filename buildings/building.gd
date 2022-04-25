extends Node2D
class_name Building

const CELL_SIZE = 16

export(Resource) var stats

var destroyed = false

func damage(hits):
	flash()
	stats.health -= hits
	if stats.health <= 0:
		die()

func die():
	destroyed = true
	$Sprite.modulate = Color.red
	#queue_free()

func rebuild():
	destroyed = false
	$Sprite.modulate = Color.white

func get_grid_size():
	var texture : Texture = $Sprite.texture
	var texture_size = texture.get_size()
	var frame_size = Vector2($Sprite.hframes, $Sprite.vframes)
	
	var grid_size = texture_size / CELL_SIZE
	grid_size /= frame_size
	return grid_size

func _on_ClickArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game = get_tree().get_nodes_in_group("main")[0]
		var repair_price = stats.price / 2
		var afford_repair = game.gold - repair_price >= 0
		if event.button_index == BUTTON_RIGHT and destroyed and afford_repair:
			game.gold -= repair_price
			rebuild()

func flash():
	$Sprite.material.set_shader_param("flash_modifer", 1.0)
	$FlashTimer.start()

func _on_FlashTimer_timeout():
	$Sprite.material.set_shader_param("flash_modifer", 0.0)
