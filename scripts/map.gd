extends Node2D

onready var ground = $Ground
onready var buildings = $Buildings

signal placed_building(building)

const NO_BUILDING = -1

# Returns if there is a building on the map
# world_position: Global position
func is_building_there(world_position):
	# Convert into grid coords
	var grid_coord = buildings.world_to_map(world_position)
	
	return buildings.get_cellv(grid_coord) == NO_BUILDING

# Places a building on the map (towers only, should be changed later)
# world_position: Global position
# building: PackedScene
func place_building(world_position, building):
	# Convert into grid coords
	var grid_coord = buildings.world_to_map(world_position)
	
	# Overwrite the tile with different building tile (to represent the type of building, useful
	# for saving and loading data if we ever get there)
	buildings.set_cellv(grid_coord, 1)
	
	# Convert into world coord to place our building
	# Note: Vector is there to offset the placement of the building assuming
	# if the sprite is actually 16x16 (might need to be dynamic depending on type
	# of building)
	var world_coord = ground.map_to_world(grid_coord) + Vector2(8, 8)
	
	# Add building to the world
	var building_instance = building.instance()
	building_instance.global_position = world_coord
	add_child(building_instance)
	
	emit_signal("placed_building", building_instance)
