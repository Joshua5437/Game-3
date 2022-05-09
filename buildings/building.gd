extends Actor
class_name Building

signal destroyed

const CELL_SIZE = 16

enum BuildingSize { _1x1, _2x2, _3x3 }

export(Resource) var stats
export(BuildingSize) var building_size = BuildingSize._1x1

# Tracks whether the building is destroyed or not
var destroyed = false


func _ready():
	health = stats.health


func take_damage(amount):
	if is_dead():
		return

	$AnimationPlayer.play("TakeDamage")
	.take_damage(amount)
	if is_dead():
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
		var repair_price = stats.get_repair_price()
		var afford_repair = PlayerData.gold - repair_price >= 0
		
		if destroyed and afford_repair:
			PlayerData.gold -= repair_price
			rebuild()


func _enter_tree():
	$AnimationPlayer.play("PlaceBuilding")
