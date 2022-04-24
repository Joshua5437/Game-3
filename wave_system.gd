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

var enemy_types = [
	EnemyType.new("Skeleton", 3, 100, 1, 1, .5, [{"name": "towers", "weight": 1}]),
	EnemyType.new("Kobold", 1, 200, 1, 1, .5, [{"name": "towers", "weight": 1}]),
]

func _ready():
	rng = RandomNumberGenerator.new()
	map = get_node(map_path)
	
	yield(get_tree(), "idle_frame")
	emit_signal("wave_spawned", wave_number)

func _spawn_wave():
	var spawn_position_node = get_node(wave_spawn_position)
	
	# Spawns a wave of enemies
	for i in range(wave_number + 1):
		var new_enemy = wave_spawn_enemy.instance()
		new_enemy.set_enemy_type(enemy_types[rng.randi_range(0,enemy_types.size()-1)])
		new_enemy.position = spawn_position_node.position
		
		tracked_enemies.push_back(new_enemy)
		new_enemy.connect("die", self, "_on_enemy_death")
		
		add_child(new_enemy)
		
		# Prevents weird movement with enemies
		yield(get_tree().create_timer(1), "timeout")

func _on_wave_started():
	_spawn_wave()
	
	# Increment the wave
	wave_number += 1
	
	# Emits signal for wave spawned
	emit_signal("wave_spawned", wave_number)

func _on_enemy_death(enemy):
	tracked_enemies.erase(enemy)
	if tracked_enemies.empty():
		emit_signal("wave_ended")
