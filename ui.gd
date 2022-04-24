extends Control

signal wave_started

onready var gold_label = $TopPanel/CenterContainer/Gold
onready var wave_label = $TopPanel/Wave
func update_gold_amount(amount):
	gold_label.text = "Gold: %s" % amount

func update_wave(wave):
	wave_label.text = "Wave: %s" % wave
func _on_Bow_pressed():
	pass # Replace with function body.


func _on_Farm_pressed():
	pass # Replace with function body.


func _on_StartWave_pressed():
	emit_signal("wave_started")
