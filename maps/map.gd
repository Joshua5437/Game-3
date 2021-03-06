extends Node2D

onready var ground = $Ground
onready var buildings = $Buildings

signal placed_building(building)
signal pathfinding_changed

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
var enemy_speed_weights = {
	"grass" : 1,
	"water" : .5,
	"rock" : 1,
	"farm" : .75,
	"wall" : 1,
	"mine" : 1,
	"enemy" : 1,
	"base" : 1
}


func setup():
	_add_points()
	_connect_points()
	$Pretty.pretty()


func _add_points():
	# Add all ground cells to AStar
	for cell in ground.get_used_cells():
		# Get the tile name from the cell
		var tile_id = ground.get_cellv(cell)
		var tile_name = ground.tile_set.tile_get_name(tile_id)
		astar.add_point(id(cell), cell, map_weights[tile_name])


func _connect_points():
	var used_cells = ground.get_used_cells()
	
	# Add connect all ground cells with their neighboring ground cells
	for cell in used_cells:
		for neighbor in CELL_NEIGHBORS:
			# Calculate the neighboring cell
			var next_cell = cell + neighbor
			
			# Check the neighbor cell is a ground cell
			if used_cells.has(next_cell):
				# Connect the cell and the neighbor
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
# Returns true if placement is sucessful. Otherwise, false
func place_building(world_position, building):
	# Convert into grid coords
	var grid_coord = buildings.world_to_map(world_position)
	
	# Check that the cell is ground
	if ground.get_cellv(grid_coord) == TileMap.INVALID_CELL:
		return false
	
	# Instance a new building
	var building_instance : Building = building.instance()
	
	# Validate building placement first
	if not is_building_placement_valid(grid_coord, building_instance):
		return false
	
	# Overwrite the tile with different building tile (to represent the type of building, useful
	# for saving and loading data if we ever get there)
	buildings.set_cellv(grid_coord, 1)
	
	# set points to really high weight if tower is there.
	# this is because they still need to path to the tower
	# just disabling them prevents enemies from being able to path close to it
	# we could also make enemies have a large attack radius to solve this issue, that might be better
	# Note: Disabled because the point is going to be removed
	#astar.set_point_weight_scale(id(grid_coord), 1000)
	
	# Get grid size from the building
	var grid_size = building_instance.get_grid_size()
	
	# Remove point from the astar pathfinding
	remove_point(grid_coord)
	
	# Remove neighbor points IF the building is 3x3
	var used_cells = ground.get_used_cells()
	if grid_size.x == 3 and grid_size.y == 3:
		for neighbor in CELL_NEIGHBORS:
			var next_cell = grid_coord + neighbor
			if astar.has_point(id(next_cell)):
				remove_point(next_cell)
			
			# Fills building slots on the building tilemap
			if next_cell in used_cells:
				buildings.set_cellv(next_cell, 1)
	
	# Convert into world coord to place our building
	# Note: Vector is there to offset the placement of the building assuming
	# if the sprite is actually 16x16 (might need to be dynamic depending on type
	# of building)
	var world_coord = ground.map_to_world(grid_coord) + CENTER_OFFSET
	
	# Setup new global position
	building_instance.global_position = world_coord
	
	# Connect signal so we can add back the point later
	building_instance.connect("die", self, "_on_building_destroyed")
	building_instance.connect("rebuilt", self, "_on_building_rebuilt")
	
	# Add building to the world
	add_child(building_instance)
	
	emit_signal("placed_building", building_instance)
	
	return true


func is_building_placement_valid(grid_pos : Vector2, building : Building):
	# Get the grid size of the building
	var grid_size = building.get_grid_size()
	
	# Check the placement is valid
	if not validate_building_grid(grid_pos, building.stats.accepted_tiles):
		return false
	
	# Assuming the cell size is 3x3, check the neighbors
	if grid_size.x == 3 and grid_size.y == 3:
		for neighbor in CELL_NEIGHBORS:
			var next_cell = grid_pos + neighbor
			if not validate_building_grid(next_cell, building.stats.accepted_tiles):
				return false
	
	return true


# Returns whether the building grid is valid or not
func validate_building_grid(grid_pos, accepted_tiles):
	# Get ground ID
	var ground_id = ground.get_cellv(grid_pos)
	
	# Check that grid position is not outside of the map
	if ground_id == TileMap.INVALID_CELL:
		return false
	
	# Check that grid position is not on "implacable" position
	if ground_id == ground.tile_set.find_tile_by_name("water"):
		return false


	# If the building has no accepted tiles, it can assumed that can be placed anywhere
	# Otherwise, this statement will go through to check
	if not accepted_tiles.empty():
		var found_acceptable_tile = false
		for tile_name in accepted_tiles:
			var temp_id = ground.tile_set.find_tile_by_name(tile_name)
			if ground_id == temp_id:
				found_acceptable_tile = true
				break
		if not found_acceptable_tile:
			return false


	# Check that there is no building in the grid position
	if buildings.get_cellv(grid_pos) != TileMap.INVALID_CELL:
		return false
	
	# Checks the edges of the map
	if grid_pos.x < 3 or \
		grid_pos.x > (MAP_SIZE - 4 ) or \
		grid_pos.y < 3 or \
		grid_pos.y > (MAP_SIZE - 4 ):
		return false 
	
	return true


# Removes grid point from A* pathfinding
func remove_point(grid_pos):
	# Convert to proper point id for A*
	var vec_id = id(grid_pos)
	
	# Remove any neighboring points to the point
	for neighbor in CELL_NEIGHBORS:
		# Convert to proper neighbor id for A*
		var neighbor_id = id(grid_pos + neighbor)
		
		# Skip if neighboring point does not exist
		if not astar.has_point(neighbor_id):
			continue
		
		# Disconnect between the point and neighbor
		astar.disconnect_points(vec_id, neighbor_id)
	
	# Remove point from the A* pathfinding
	astar.remove_point(vec_id)
	
	# Emit signal since A* pathfinding has changed
	emit_signal("pathfinding_changed")


# Adds grid point to A* pathfinding
func add_point(grid_pos):
	# Convert to proper point id for A*
	var vec_id = id(grid_pos)
	
	# Get the tile name from the cell for weight
	var tile_id = ground.get_cellv(grid_pos)
	var tile_name = ground.tile_set.tile_get_name(tile_id)
	
	# Adds point to A* pathfinding
	astar.add_point(vec_id, grid_pos, map_weights[tile_name])
	
	# Remove any neighboring points to the point
	for neighbor in CELL_NEIGHBORS:
		# Convert to proper neighbor id for A*
		var neighbor_id = id(grid_pos + neighbor)
		
		# Skip if neighboring point does not exist
		if not astar.has_point(neighbor_id):
			continue
		
		# Connect between the point and neighbor
		astar.connect_points(vec_id, neighbor_id)
	
	# Emit signal since A* pathfinding has changed
	emit_signal("pathfinding_changed")


# Returns A* path using from and to positions
func get_path_to_point(from: Vector2, to: Vector2):
	# Convert from world position to grid position
	var from_grid_pos = ground.world_to_map(from)
	var to_grid_pos = ground.world_to_map(to)
	
	# Get ids for A* pathfinding using the closest point method
	var from_id = astar.get_closest_point(from_grid_pos)
	var to_id = astar.get_closest_point(to_grid_pos)
	
	# Get point path using A*
	var path = astar.get_point_path(from_id, to_id)
	
	# Convert all path points into world position
	for i in len(path):
		path[i] = ground.map_to_world(path[i]) + CENTER_OFFSET
	
	return path


func get_cell_weight(world_position: Vector2):
	# Convert world position to grid position
	var grid_pos = ground.world_to_map(world_position)
	
	# Find tile name by fetching and using the cell's tile id
	var cell_id = ground.get_cellv(grid_pos)
	var cell_tile_name = ground.tile_set.tile_get_name(cell_id)
	
	# Return tile weight using the tile name
	return map_weights[cell_tile_name]


func get_cell_speed_modifier(world_position):
	var grid_pos = ground.world_to_map(world_position)
	
	# Find tile name by fetching and using the cell's tile id
	var cell_id = ground.get_cellv(grid_pos)
	var cell_tile_name = ground.tile_set.tile_get_name(cell_id)
	
	# Return tile weight using the tile name
	return enemy_speed_weights[cell_tile_name]


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


func preset_edge_position(edge):
	var grid_pos : Vector2
	
	match edge:
		# North
		"North":
			grid_pos = Vector2(randi() % MAP_SIZE, 0)
		# East
		"East":
			grid_pos = Vector2(MAP_SIZE - 1, randi() % MAP_SIZE)
		# South
		"South":
			grid_pos = Vector2(randi() % MAP_SIZE, MAP_SIZE - 1)
		# West
		"West":
			grid_pos = Vector2(0, randi() % MAP_SIZE)
		_:
			return randomize_edge_position()
	
	var world_pos = ground.map_to_world(grid_pos) + CENTER_OFFSET
	return world_pos


# Once a building is destroyed, we should add back the point
func _on_building_destroyed(building : Building):
	var grid_pos = ground.world_to_map(building.global_position)
	add_point(grid_pos)
	
	# Add points if size bigger than 1x1
	match building.building_size:
		Building.BuildingSize._3x3:
			for neighbor in CELL_NEIGHBORS:
				add_point(grid_pos + neighbor)


# Once a building is rebuilt, we should remove point
func _on_building_rebuilt(building : Building):
	var grid_pos = ground.world_to_map(building.global_position)
	remove_point(grid_pos)
	
	# Remove points if size bigger than 1x1
	match building.building_size:
		Building.BuildingSize._3x3:
			for neighbor in CELL_NEIGHBORS:
				remove_point(grid_pos + neighbor)
