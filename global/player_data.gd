extends Node

signal gold_changed(amount)

const BASE_GOLD = 50

var gold = 50 setget set_gold

func reset():
	gold = BASE_GOLD


func set_gold(amount):
	gold = amount
	emit_signal("gold_changed", amount)
