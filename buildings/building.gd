extends Node2D

export(Resource) var stats

var destroyed = false

func damage(hits):
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

func _on_ClickArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		var game = get_tree().get_nodes_in_group("main")[0]
		var repair_price = stats.price / 2
		var afford_repair = game.gold - repair_price >= 0
		if event.button_index == BUTTON_RIGHT and destroyed and afford_repair:
			game.gold -= repair_price
			rebuild()
