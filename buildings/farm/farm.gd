extends "res://buildings/building.gd"

signal gold_produced(amount)

var gold_production_amount = 5

func _on_ProduceTimer_timeout():
	emit_signal("gold_produced", gold_production_amount)
