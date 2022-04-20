extends Node2D

onready var map = $Navigation/Map
onready var ui = $CanvasLayer/UserInterface

# Used to place the towers on the map
export(Array) var constructions
var current_construction = null

# Player stats
export(int) var gold = 100 # Represents player's cash balance

func _ready():
	# This will show accruate information about gold balance
	ui.update_gold_amount(gold)

func _process(_delta):
	# Get global mouse position
	var global_mouse_position = get_global_mouse_position()
	var num_constructions = len(constructions)
	
	# Choose a tower to construct based on the numeric keys
	if Input.is_key_pressed(KEY_1) and num_constructions >= 1:
		current_construction = constructions[0]
	if Input.is_key_pressed(KEY_2) and num_constructions >= 2:
		current_construction = constructions[1]
	
	# Places tower on the map if mosue left button is pressed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) \
		and map.is_building_there(global_mouse_position) \
		and current_construction != null \
		and gold - current_construction.stats.price >= 0:
		
		# Substract from balance and update UI
		gold -= current_construction.stats.price
		ui.update_gold_amount(gold)
		
		map.place_building(global_mouse_position, current_construction.scene)

# Used for signal call. Bascially increases the gold amount and updates UI
func _on_gold_produced(amount):
	gold += amount
	ui.update_gold_amount(gold)

func _on_Map_placed_building(building):
	if building.has_signal("gold_produced"):
		building.connect("gold_produced", self, "_on_gold_produced")
