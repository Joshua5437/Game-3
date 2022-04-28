extends TileMap

export(NodePath) var ground_path

onready var ground : TileMap = get_node(ground_path)

func _ready():
	pretty_grass("grass", 4)

func pretty_grass(grass_name, variation_num):
	var grass_id = ground.tile_set.find_tile_by_name(grass_name)
	var grass_replace = []
	
	# Fill replacements with names
	for i in range(variation_num):
		var temp_name = "%s-%s" % [grass_name, i]
		grass_replace.push_back(tile_set.find_tile_by_name(temp_name))
	
	# Get all grass cells
	var used_cells = ground.get_used_cells_by_id(grass_id)
	
	# Replace all grass cells with pretty grass
	for cell in used_cells:
		var cell_id = Global.cantorv(cell)
		var index = int(cell_id) % len(grass_replace)
		set_cellv(cell, grass_replace[index])
