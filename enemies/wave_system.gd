extends Node

signal wave_spawned(wave_number)
signal wave_ended

export(NodePath) var map_path
var map = null

export(NodePath) var wave_spawn_position
export(PackedScene) var wave_spawn_enemy

# Tracks whether there is wave happening right now
var current_wave = false
var wave_number = 0

var rng : RandomNumberGenerator

var tracked_enemies = []

var wave_data : Dictionary
#var infinite_wave_increase_amount: int
#var current_infinite_increase := 0
var enemy_types = {
	"Skeleton" : EnemyType.new("Skeleton", 3, 100, 1, 1, .5, [{"name": "towers", "weight": 1}]),
	"Kobold" : EnemyType.new("Kobold", 1, 200, 1, 1, .5, [{"name": "towers", "weight": 1}]),
}

func _ready():
	rng = RandomNumberGenerator.new()
	map = get_node(map_path)
	
	yield(get_tree(), "idle_frame")
	emit_signal("wave_spawned", wave_number)
	var file = File.new()
	if file.open("res://enemies/waves.json", File.READ) != OK:
		return
	wave_data = JSON.parse(file.get_as_text()).result
	#infinite_wave_increase_amount = wave_data["infinite_waves"]["increase_amount"]

func _spawn_wave():
	var wave_groups: Array
	var infinite = false
	print(wave_data)
	if (wave_number < wave_data["waves"].size()):
		wave_groups = wave_data["waves"][wave_number]
	else:
		infinite = true
		wave_groups = wave_data["infinite_waves"]["wavegroups"]
		
	var new_position = map.randomize_edge_position()
	
	# Spawns a wave of enemies
	for group in wave_groups:
		print(_spawn_wave_group(group, infinite))
	"""
	for i in range(wave_number + 1):
		var new_enemy = wave_spawn_enemy.instance()
		new_enemy.set_enemy_type(enemy_types[rng.randi_range(0,enemy_types.size()-1)])
		new_enemy.position = new_position
		
		tracked_enemies.push_back(new_enemy)
		new_enemy.connect("die", self, "_on_enemy_death")
		
		add_child(new_enemy)
		
		# Prevents weird movement with enemies
		yield(get_tree().create_timer(1), "timeout")
	"""
func _spawn_wave_group(group, is_infinite):
	print("huh")
	#var direction: String
	var new_position = map.preset_edge_position(group["direction"])
	for i in range(group["count"]):
		var enemy_choice = group["enemies"][rng.randi_range(0, group["enemies"].size()-1)]
		
		var new_enemy = wave_spawn_enemy.instance()
		new_enemy.set_enemy_type(enemy_types[enemy_choice])
		new_enemy.position = new_position
		
		tracked_enemies.push_back(new_enemy)
		new_enemy.connect("die", self, "_on_enemy_death")
		
		add_child(new_enemy)
		
		# Prevents weird movement with enemies
		yield(get_tree().create_timer(group["delay"]), "timeout")
	if (is_infinite):
		group["count"] += group["increase_amount"]
	return 1
func _on_wave_started():
	print("hu")
	_spawn_wave()
	
	# Increment the wave
	wave_number += 1
	
	# Emits signal for wave spawned
	emit_signal("wave_spawned", wave_number)

func _on_enemy_death(enemy):
	tracked_enemies.erase(enemy)
	if tracked_enemies.empty():
		emit_signal("wave_ended")
