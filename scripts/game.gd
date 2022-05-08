extends Node2D

signal gold_updated(gold)
signal game_over
signal paused

signal deselect_construction

onready var map = $Map
onready var buildSound = $BuildSound
# Player stats
# Represents player's cash balance
export(int) var gold = 100 setget set_gold
export(int) var wave_gold = 50
var current_construction = null

func _ready():
	_setup()


func _setup():
	randomize()
	
	GlobalSignals.connect("keep_destroyed", self, "game_over")
	emit_signal("gold_updated", gold)


func _unhandled_input(event):
	if event.is_action_pressed("pause") and current_construction == null:
		emit_signal("paused")
		get_tree().paused = true
	
	if event.is_action_pressed("deselect") and current_construction != null:
		current_construction = null
		emit_signal("deselect_construction")
		map.get_node("TooCloseToEdge").visible = false
	
	if event is InputEventMouseButton:
		var global_mouse_position = get_global_mouse_position()
		
		# Places tower on the map if mosue left button is pressed
		if event.pressed and event.button_index == BUTTON_LEFT \
			and is_valid_placement(global_mouse_position):
			var success = map.place_building(global_mouse_position, current_construction.scene)
			
			if success:
				buildSound.play()

func is_valid_placement(world_position):
	if current_construction == null:
		return false
	if not map.is_building_there(world_position):
		return false
	
	# Bypass cost check for placing a keep
	if current_construction.stats.type == BuildingStats.Type.Keep:
		return true
	
	return gold - current_construction.stats.price >= 0

func set_gold(value):
	gold = value
	emit_signal("gold_updated", gold)

func _on_Map_placed_building(building):
	var build_stats : BuildingStats = building.stats
	
	# Substracts balance if the building is not a keep
	if not build_stats.type == 2:
		# Substract from balance
		gold -= build_stats.price
	
	# Deselect current construction if building is a keep
	if building.is_in_group("keep"):
		current_construction = null
		emit_signal("deselect_construction")
		map.get_node("TooCloseToEdge").visible = false
		GlobalSignals.emit_signal("keep_placed")
	
	emit_signal("gold_updated", gold)

func _on_wave_ended():
	var farms = get_tree().get_nodes_in_group("econ")
	for farm in farms:
		if (farm.destroyed != true):
			gold += farm.stats.gold_production
	
	# Gives some gold to the player for completing a wave
	gold += wave_gold
	
	# Emit signal to show gold updated
	emit_signal("gold_updated", gold)
	
	# Runs this to check if the game is actually over
	game_over()

func _on_mainUI_construction_selected(construction_stats):
	map.get_node("TooCloseToEdge").visible = true
	current_construction = construction_stats

func game_over():
	var keep = get_tree().get_nodes_in_group("keep")[0]
	if not keep.destroyed:
		return
	if gold >= keep.stats.get_repair_price():
		return
	$LoseSound.play()
	emit_signal("game_over")
