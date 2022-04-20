extends Control

onready var gold_label = $Gold

func update_gold_amount(amount):
	gold_label.text = "Gold: %s" % amount
