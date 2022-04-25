extends Control

signal wave_started
signal construction_selected(construction_stats)

onready var gold_label = $TopPanel/CenterContainer/Gold
onready var wave_label = $TopPanel/Wave

onready var start_wave_button = $MarginContainer/StartWave

func update_gold_amount(amount):
	gold_label.text = "Gold: %s" % amount

func update_wave(wave):
	wave_label.text = "Wave: %s" % wave

func _on_construction_button_pressed(stats):
	emit_signal("construction_selected", stats)

func _on_StartWave_pressed():
	emit_signal("wave_started")
	start_wave_button.disabled = true

func _on_wave_ended():
	start_wave_button.disabled = false
