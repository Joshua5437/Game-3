extends Node

signal game_over
signal gold_changed(amount)

const BASE_GOLD = 50

var gold = 50 setget set_gold
var game_over = false setget ,is_game_over


func _ready():
	gold = BASE_GOLD

func reset():
	game_over = false
	gold = BASE_GOLD


func set_gold(amount):
	gold = amount
	emit_signal("gold_changed", amount)


func declare_game_over():
	game_over = true
	emit_signal("game_over")


func is_game_over():
	return game_over
