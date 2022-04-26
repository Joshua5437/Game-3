extends Control

signal wave_started
signal construction_selected(construction_stats)

onready var gold_label = $TopPanel/CenterContainer/Gold
onready var wave_label = $TopPanel/Wave

onready var start_wave_button = $MarginContainer/StartWave
onready var keep_construction_button = $Buildings/GridContainer/Tower

onready var game_over_label = $GameOver

func _ready():
	GlobalSignals.connect("keep_placed", self, "_on_building_keep_placed")

func update_gold_amount(amount):
	gold_label.text = "Gold: %s" % amount

func update_wave(wave):
	wave_label.text = "Wave: %s" % wave

func _on_construction_button_pressed(stats):
	emit_signal("construction_selected", stats)

func _on_StartWave_pressed():
	emit_signal("wave_started")
	start_wave_button.disabled = true
	print("h")

func _on_wave_ended():
	start_wave_button.disabled = false

func _on_building_keep_placed():
	keep_construction_button.disabled = true
	start_wave_button.disabled = false

func display_game_over():
	game_over_label.show()
