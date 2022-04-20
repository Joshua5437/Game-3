extends Node2D

onready var map = $Navigation/Map

# Used to place the towers on the map
export(Resource) var construction

export(int) var gold = 100 # Represents player's cash balance

func _process(delta):
	# Get global mouse position
	var global_mouse_position = get_global_mouse_position()
	
	# Places tower on the map if mosue left button is pressed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) \
		and map.is_building_there(global_mouse_position) \
		and gold - construction.stats.price >= 0:
		
		gold -= construction.stats.price
		print("placed tower | gold: %s" % gold)
		map.place_building(global_mouse_position, construction.scene)
	
