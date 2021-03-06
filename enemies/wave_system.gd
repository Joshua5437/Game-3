extends Node

signal wave_spawned(wave_number)
signal wave_ended
signal wave_group_completed
signal final_boss_killed

export(NodePath) var map_path
var map = null

export(PackedScene) var final_boss
var final_boss_killed = false
export(int) var final_wave_number = 10

export(Dictionary) var enemies = {} 

# Tracks whether there is wave happening right now
var current_wave = false
export var wave_number = 0

var rng : RandomNumberGenerator

var tracked_enemies = []

var wave_data : Dictionary
#var infinite_wave_increase_amount: int
#var current_infinite_increase := 0
#var enemy_types = {
#	"Zombie" : EnemyType.new("Zombie", 3, 100, 16, 1, .5, [{"name": "towers", "weight": 1}], 11),
#	"Wolf" : EnemyType.new("Kobold", 1, 200, 16, 1, .5, [{"name": "towers", "weight": 1}], 19),
#	"Goblin" : EnemyType.new("Goblin", 2, 100, 16, 1, .25, [{"name": "econ", "weight": 1}], 20),
#	"Troll" : EnemyType.new("Troll", 5, 50, 16, 1, .25, [{"name" : "towers", "weight": 1}], 4),
#	"Skeleton" : EnemyType.new("Skeleton", 3, 100, 96, 1, 2, [{"name" : "towers", "weight" : 1}], 3, true),
#}
#if you want to do enemy types in the editor feel free, but my system relies on dicts and godot no like
#basically a pain and kind of equally hard to tell whats going on once you add everything
#probably easier to edit enemies, because the variables are clearer,
#but really awful for adding new ones

#export(Dictionary) var enemy_types
func _ready():
	rng = RandomNumberGenerator.new()
	map = get_node(map_path)
	
	yield(get_tree(), "idle_frame")
	emit_signal("wave_spawned", wave_number)
	var file = File.new()
	if file.open("res://data/waves.json", File.READ) != OK:
		return
	wave_data = JSON.parse(file.get_as_text()).result
	#infinite_wave_increase_amount = wave_data["infinite_waves"]["increase_amount"]

func _spawn_wave():
	var wave_groups: Array
	var infinite = false
	
	if (wave_number < wave_data["waves"].size()):
		wave_groups = wave_data["waves"][wave_number]
	else:
		infinite = true
		wave_groups = wave_data["infinite_waves"]["wavegroups"]
		
	var new_position = map.randomize_edge_position()
	
	# Spawns the wave groups in sequence
	for group in wave_groups:
		yield(_spawn_wave_group(group, infinite), "completed")
	
func _spawn_wave_group(group, is_infinite):
	
	#finds the position to spawn this group
	var new_position = map.preset_edge_position(group["direction"])
	#loops through every enemy in the group and spawns it
	for i in range(group["count"]):
		if group["spread_type"] == "Random":
			new_position = map.preset_edge_position(group["direction"])
		var enemy_choice = group["enemies"][rng.randi_range(0, group["enemies"].size()-1)]
		
		var new_enemy = enemies[enemy_choice].instance()
		new_enemy.setup(map)
		new_enemy.position = new_position
		
		tracked_enemies.push_back(new_enemy)
		new_enemy.connect("die", self, "_on_enemy_death")
		
		add_child(new_enemy)
		
		# Prevents weird movement with enemies
		yield(get_tree().create_timer(group["delay"]), "timeout")
	#makes enemy amounts increase infinitely
	if (is_infinite):
		group["count"] += group["increase_amount"]
	#emit_signal("wave_group_completed")

func _spawn_final_boss():
	var new_position = map.randomize_edge_position()
	var new_boss = final_boss.instance()
	new_boss.setup(map)
	new_boss.position = new_position
	new_boss.connect("die", self, "_on_enemy_death")
	tracked_enemies.push_back(new_boss)
	add_child(new_boss)

func _on_wave_started():
	_spawn_wave()
	
	# Increment the wave
	wave_number += 1
	
	if wave_number == final_wave_number:
		_spawn_final_boss()
	
	# Emits signal for wave spawned
	emit_signal("wave_spawned", wave_number)

func _on_enemy_death(enemy):
	tracked_enemies.erase(enemy)

	if enemy.is_in_group("boss"):
		print("killed boss")
		final_boss_killed = true
	
	if tracked_enemies.empty():
		emit_signal("wave_ended")
		if final_boss_killed:
			emit_signal("final_boss_killed")
			final_boss_killed = false
	
