extends "res://maps/map.gd"

const TILE_NAMES = ["grass", "rock"]


func _setup():
	ground.clear()
	generate_map()
	$Pretty.pretty()


# Procedurally generate a map
func generate_map():
	var rng = RandomNumberGenerator.new()
	var tile_set = ground.tile_set
	
	rng.randomize()
	
	# Fetch the ids for the ground tiles
	var grass_id = tile_set.find_tile_by_name("grass")
	var water_id = tile_set.find_tile_by_name("water")
	var rock_id = tile_set.find_tile_by_name("rock")
	
	# Fill the map with grass
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			ground.set_cell(x, y, grass_id)
	
	# Randomly pick tiles to be rock
	#warning-ignore:unused_variable
	for n in range((randi() % 10) + 1):
		var x = rng.randi() % MAP_SIZE
		var y = rng.randi() % MAP_SIZE
		ground.set_cell(x, y, rock_id)
	
	# Generate rock clusters
	#warning-ignore:unused_variable
	for n in range((randi() % 6) + 3):
		for cell in ground.get_used_cells_by_id(rock_id):
			for neighbor in Global.NEIGHOR_CELLS:
				var next_cell = cell + neighbor
				var next_cell_id = ground.get_cellv(next_cell)
				
				if next_cell_id == rock_id or next_cell_id == TileMap.INVALID_CELL:
					continue
				if rng.randi() % 2 == 0:
					ground.set_cellv(next_cell, rock_id)
	
	# Generate a river
	var offset_amount = 7 # in cells
	var start_point = Vector2(0, rng.randi_range(0, MAP_SIZE-1))
	var river_points = [start_point]
	for n in range(1, 5):
		var x = int(MAP_SIZE * n * 0.25)
		var y = start_point.y + rng.randi_range(0, offset_amount)
		y = int(clamp(y, 0, MAP_SIZE - 1))
		
		var new_point = Vector2(x, y)
		river_points.append(new_point)
	
	print(river_points)
	
	for i in range(len(river_points) - 1):
		Global.plot_linev(river_points[i], river_points[i+1])
