extends Node2D

signal gold_updated(gold)
signal game_over
signal paused

onready var map = $Map

# Player stats
# Represents player's cash balance
export(int) var gold = 100 setget set_gold
var current_construction = null

func _ready():
	randomize()
	
	GlobalSignals.connect("keep_destroyed", self, "game_over")
	emit_signal("gold_updated", gold)

func _unhandled_input(event):
	if event.is_action_pressed("pause") and current_construction == null:
		emit_signal("paused")
		get_tree().paused = true
	
	if event.is_action_pressed("deselect") and current_construction != null:
		current_construction = null
	
	if event is InputEventMouseButton:
		var global_mouse_position = get_global_mouse_position()
		
		# Places tower on the map if mosue left button is pressed
		if event.pressed and event.button_index == BUTTON_LEFT \
			and is_valid_placement(global_mouse_position):
			map.place_building(global_mouse_position, current_construction.scene)
	
	# Choose a tower to construct based on the numeric keys
	# TODO: Fix building shortcuts later
#	if Input.is_key_pressed(KEY_1) and num_constructions >= 1:
#		_select_bow()
#	if Input.is_key_pressed(KEY_2) and num_constructions >= 2:
#		_select_farm()
#	if Input.is_key_pressed(KEY_3) and num_constructions >= 3:
#		current_construction = constructions[2]
	
	# Spawns enemies (meant for presentation and testing)
	# TODO: Fix wave start shortcut later
#	if Input.is_key_pressed(KEY_Q) and not spawn_button_pressed:
#		_spawn_wave()
#	elif not Input.is_key_pressed(KEY_Q) and spawn_button_pressed:
#		spawn_button_pressed = false

func is_valid_placement(world_position):
	if current_construction == null:
		return false
	if not map.is_building_there(world_position):
		return false
	
	# Bypass cost check for placing a keep
	if current_construction.stats.type == BuildingStats.Type.Keep:
		return true
	
	return gold - current_construction.get_price() >= 0

func set_gold(value):
	gold = value
	emit_signal("gold_updated", gold)

func _on_Map_placed_building(building):
	var build_stats : BuildingStats = building.stats
	
	# Substracts balance if the building is not a keep
	if not build_stats.is_keep():
		# Substract from balance
		gold -= build_stats.price
	
	# Deselect current construction if building is a keep
	if building.is_in_group("keep"):
		current_construction = null
		GlobalSignals.emit_signal("keep_placed")
	
	emit_signal("gold_updated", gold)

func _on_wave_ended():
	var farms = get_tree().get_nodes_in_group("farm")
	for farm in farms:
		if (farm.destroyed != true):
			gold += farm.gold_production_amount
	emit_signal("gold_updated", gold)
	game_over()

func _on_mainUI_construction_selected(construction_stats):
	current_construction = construction_stats

func game_over():
	var keep = get_tree().get_nodes_in_group("keep")[0]
	if not keep.destroyed:
		return
	if gold >= keep.stats.get_repair_price():
		return
	emit_signal("game_over")
