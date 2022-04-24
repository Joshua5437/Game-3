extends Node2D

onready var map = $Map
onready var ui = $CanvasLayer/mainUI

# Used to place the towers on the map
export(Array) var constructions
var current_construction = null

# Player stats
# Represents player's cash balance
export(int) var gold = 100 setget set_gold
var wave := 1;

# Enemy waves
export(NodePath) var wave_spawn_position
export(PackedScene) var wave_spawn_enemy
var tracked_enemies = []
var spawn_button_pressed = false


var enemy_types = [
	EnemyType.new("Skeleton", 3, 100, 1, 1, .5, [{"name": "towers", "weight": 1}]),
	EnemyType.new("Kobold", 1, 200, 1, 1, .5, [{"name": "towers", "weight": 1}]),
]
var rng : RandomNumberGenerator

func _ready():
	
	rng = RandomNumberGenerator.new()
	# This will show accruate information about gold balance
	ui.update_gold_amount(gold)
	ui.update_wave(wave)
	
	#probably a better way to do this (barely understand the signal system in godot)
	ui.get_node("Buildings/GridContainer/Bow").connect("pressed", self, "_select_bow")
	ui.get_node("Buildings/GridContainer/Farm").connect("pressed", self, "_select_farm")
	ui.get_node("MarginContainer/StartWave").connect("pressed", self, "_spawn_wave")
func _process(_delta):
	# Get global mouse position
	var global_mouse_position = get_global_mouse_position()
	var num_constructions = len(constructions)
	
	# Choose a tower to construct based on the numeric keys
	if Input.is_key_pressed(KEY_1) and num_constructions >= 1:
		_select_bow()
	if Input.is_key_pressed(KEY_2) and num_constructions >= 2:
		_select_farm()
	
	# Spawns enemies (meant for presentation and testing)
	if Input.is_key_pressed(KEY_Q) and not spawn_button_pressed:
		_spawn_wave()
	elif not Input.is_key_pressed(KEY_Q) and spawn_button_pressed:
		spawn_button_pressed = false

func _unhandled_input(event):
	if event is InputEventMouseButton:
		var global_mouse_position = get_global_mouse_position()
		
		# Places tower on the map if mosue left button is pressed
		if event.pressed and event.button_index == BUTTON_LEFT \
			and is_valid_placement(global_mouse_position):
			
			# Substract from balance and update UI
			gold -= current_construction.stats.price
			ui.update_gold_amount(gold)
			
			map.place_building(global_mouse_position, current_construction.scene)

func is_valid_placement(world_position):
	return map.is_building_there(world_position) \
		and current_construction != null \
		and gold - current_construction.stats.price >= 0

func set_gold(value):
	gold = value
	if ui != null:
		ui.update_gold_amount(gold)

# Used for signal call. Bascially increases the gold amount and updates UI
func _on_gold_produced(amount):
	gold += amount
	ui.update_gold_amount(gold)

func _select_bow():
	current_construction = constructions[0]
func _select_farm():
	current_construction = constructions[1]
func _on_Map_placed_building(building):
	if building.has_signal("gold_produced"):
		building.connect("gold_produced", self, "_on_gold_produced")

func _spawn_wave():
	spawn_button_pressed = true
	var spawn_position_node = get_node(wave_spawn_position)
	
	# Spawns a wave of enemies
	for i in range(wave + 1):
		var new_enemy = wave_spawn_enemy.instance()
		new_enemy.set_enemy_type(enemy_types[rng.randi_range(0,enemy_types.size()-1)])
		new_enemy.position = spawn_position_node.position
		
		tracked_enemies.push_back(new_enemy)
		new_enemy.connect("die", self, "_handle_enemy_death")
		
		add_child(new_enemy)
		
		# Prevents weird movement with enemies
		yield(get_tree().create_timer(1), "timeout")
	
	# Increment the wave
	wave += 1
	
	# Updates UI
	ui.update_wave(wave)

func _handle_enemy_death(enemy):
	print("enemy death")
	tracked_enemies.erase(enemy)
	
	if tracked_enemies.empty():
		var farms = get_tree().get_nodes_in_group("farm")
		for farm in farms:
			gold += farm.gold_production_amount
		ui.update_gold_amount(gold)
