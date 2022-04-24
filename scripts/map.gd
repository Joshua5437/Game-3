extends Node2D

onready var ground = $Ground
onready var buildings = $Buildings

signal placed_building(building)

const NO_BUILDING = -1
onready var astar = AStar2D.new()

const MAP_SIZE = 64
const CENTER_OFFSET = Vector2(8,8)
const CELL_SIZE = 16

#map weights for the pathfinding

var map_weights = [
	1, #0 Grass
	5, #1 Water
	1, #2 Rock
	4, #3 Farm
	1, #4 Wall
	1, #5 Black
	1, #6 Enemy
	1, #7 Base
	1, #Extra
	1, #Extra
	
]
func _ready():
	#llop through all tiles to create the path nodes
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var tile_weight = map_weights[ground.get_cell(x,y)]
			astar.add_point(x * MAP_SIZE + y,ground.map_to_world(Vector2(x,y)) + CENTER_OFFSET, tile_weight)
			
	#connect them together
	for x in range(MAP_SIZE -1):
		for y in range(MAP_SIZE -1):
			astar.connect_points(x*MAP_SIZE+y, (x+1)*MAP_SIZE+y)
			astar.connect_points(x*MAP_SIZE+y, (x+1)*MAP_SIZE+y+1)
			astar.connect_points(x*MAP_SIZE+y, (x+1)*MAP_SIZE+y+1)
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
	#set points to really high weight if tower is there.
	#this is because they still need to path to the tower
	#just disabling them prevents enemies from being able to path close to it
	#we could also make enemies have a large attack radius to solve this issue, that might be better
	astar.set_point_weight_scale(grid_coord.x * MAP_SIZE + grid_coord.y, 1000)
	# Convert into world coord to place our building
	# Note: Vector is there to offset the placement of the building assuming
	# if the sprite is actually 16x16 (might need to be dynamic depending on type
	# of building)
	var world_coord = ground.map_to_world(grid_coord) + CENTER_OFFSET
	
	# Add building to the world
	var building_instance = building.instance()
	building_instance.global_position = world_coord
	add_child(building_instance)
	
	emit_signal("placed_building", building_instance)

func get_path_to_point(from: Vector2, to: Vector2):
	var from_id = astar.get_closest_point(from)
	var to_id = astar.get_closest_point(to)
	return astar.get_point_path(from_id, to_id)
	
func get_cell_weight(world_position: Vector2):
	return map_weights[ground.get_cell(world_position.x/CELL_SIZE, world_position.y/CELL_SIZE)]

# Return random position on the map edge
func randomize_edge_position():
	var edge_num = randi() % 4
	var grid_pos : Vector2
	match edge_num:
		# North
		0:
			grid_pos = Vector2(randi() % MAP_SIZE, 0)
		# East
		1:
			grid_pos = Vector2(MAP_SIZE - 1, randi() % MAP_SIZE)
		# South
		2:
			grid_pos = Vector2(randi() % MAP_SIZE, MAP_SIZE - 1)
		# West
		3:
			grid_pos = Vector2(0, randi() % MAP_SIZE)
	
	var world_pos = ground.map_to_world(grid_pos) + CENTER_OFFSET
	return world_pos
