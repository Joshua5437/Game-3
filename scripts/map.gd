extends Node2D

onready var ground = $Ground
onready var buildings = $Buildings

signal placed_building(building)

const NO_BUILDING = -1
onready var astar = AStar2D.new()

const MAP_SIZE = 64
const CENTER_OFFSET = Vector2(8,8)
const CELL_SIZE = 16

const CELL_NEIGHBORS = [
	Vector2.UP, 
	Vector2.DOWN, 
	Vector2.LEFT, 
	Vector2.RIGHT, 
	Vector2(1, -1), 
	Vector2(1, 1),
	Vector2(-1, 1),
	Vector2(-1, -1)
]

# Map weights for the pathfinding
var map_weights = {
	"grass" : 1,
	"water" : 5,
	"rock" : 1,
	"farm" : 4,
	"wall" : 1,
	"mine" : 1,
	"enemy" : 1,
	"base" : 1
}

func _ready():
	_add_points()
	_connect_points()

func _add_points():
	# Add all ground cells to AStar
	for cell in ground.get_used_cells():
		astar.add_point(id(cell), cell)

func _connect_points():
	var used_cells = ground.get_used_cells()
	
	# Add connect all ground cells with their neighboring ground cells
	for cell in used_cells:
		for neighbor in CELL_NEIGHBORS:
			var next_cell = cell + neighbor
			if used_cells.has(next_cell):
				astar.connect_points(id(cell), id(next_cell))

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
	
	# Check that the cell is ground
	if ground.get_cellv(grid_coord) == TileMap.INVALID_CELL:
		return
	
	# Overwrite the tile with different building tile (to represent the type of building, useful
	# for saving and loading data if we ever get there)
	buildings.set_cellv(grid_coord, 1)
	
	# set points to really high weight if tower is there.
	# this is because they still need to path to the tower
	# just disabling them prevents enemies from being able to path close to it
	# we could also make enemies have a large attack radius to solve this issue, that might be better
	astar.set_point_weight_scale(id(grid_coord), 1000)
	
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
	# Convert from world position to grid position
	# so it can be id
	var from_ = id(ground.world_to_map(from))
	var to_ = id(ground.world_to_map(to))
	var path = astar.get_point_path(from_, to_)
	for i in len(path):
		path[i] = ground.map_to_world(path[i])
	return path
	
func get_cell_weight(world_position: Vector2):
	# Convert world position to grid position
	var grid_pos = ground.world_to_map(world_position)
	
	# Find tile name by fetching and using the cell's tile id
	var cell_id = ground.get_cellv(grid_pos)
	var cell_tile_name = ground.tile_set.tile_get_name(cell_id)
	
	# Return tile weight using the tile name
	return map_weights[cell_tile_name]

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

func get_grid_center_position(world_position):
	var grid_pos = ground.world_to_map(world_position)
	var new_pos = ground.map_to_world(grid_pos) + CENTER_OFFSET
	return new_pos

# Returns unqiue id using cantor pairing function
func id(vec : Vector2):
	return (vec.x + vec.y) * (vec.x + vec.y + 1) / 2 + vec.y
