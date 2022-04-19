extends Node2D

onready var map = $Navigation/Map

# Used to place the towers on the map
export(PackedScene) var tower

func _process(delta):
	# Get global mouse position
	var global_mouse_position = get_global_mouse_position()
	
	# Places tower on the map if mosue left button is pressed
	if Input.is_mouse_button_pressed(BUTTON_LEFT) \
		and map.is_building_there(global_mouse_position):
		map.place_building(global_mouse_position, tower)
		print("placed tower")
