#const Queue = preload("res://scripts/priorityQueue.gd")
#
class_name Pathfinder
#takes in a 2d array of map weights as ints, -1 means unpassable.
#assumes that the outside edges are set to -1
#allows for rectangular grids, if they are uniform
static func djikstras(map_weights: Array, startLoc: Vector2):
	var frontier = PriorityQueue.new()
	#2d array storing where each vector came from
	var completed_vector_map = ReallyRandomFunctions.build_2d_array(
			map_weights.size(), map_weights[0].size(), 0)
	#2d array stroring the cumulative mapweights
	#initialize with each weight being effectively infinity (max int size in godot)
	#if a computed weight exceeds this value i fear the apocalypse
	var completed_weight_map = ReallyRandomFunctions.build_2d_Array(
			map_weights.size(), map_weights[0].size(), 9223372036854775807)
	frontier.add_value(startLoc, 0)
	completed_vector_map[startLoc.x][startLoc.y] = startLoc
	completed_weight_map[startLoc.x][startLoc.y] = 0
	while frontier.is_empty() == false:
		var nextSquare = frontier.pop_lowest()
		for neighbor in get_neighbors(nextSquare["value"]):
			#potential weight to put in the space
			#computed by adding the weight of that square to the existing completed weight
			var potential_new_weight = completed_vector_map[nextSquare["value"].x][nextSquare["value"].y] + map_weights[neighbor.x][neighbor.y]
			#check if it possible to go to that square
			#and there is not already a faster path there.
			
			if (map_weights[neighbor.x][neighbor.y] != -1 and 
					completed_weight_map[neighbor.x][neighbor.y] > potential_new_weight):
						
				#adds the weight to the map and add its to the frontier to explore neighbors
				completed_weight_map[neighbor.x][neighbor.y] = potential_new_weight
				completed_vector_map[neighbor.x][neighbor.y] = neighbor
				frontier.add_value(neighbor, potential_new_weight) 
				
	return {
		"vector_map" : completed_vector_map,
		"weight_map" : completed_weight_map,
	}
	
	
#helper function to get neigbors,
static func get_neighbors( currentLoc: Vector2):
	return [
		#(assuming 0,0 is bottom left)
		#right
		Vector2(currentLoc.x+1, currentLoc.y),
		#left
		Vector2(currentLoc.x-1, currentLoc.y),
		#above
		Vector2(currentLoc.x, currentLoc.y+1),
		#bottom
		Vector2(currentLoc.x, currentLoc.y+1),
	]
	
#creates a path that enemies can follow
#uses non cumulative weights because we really only care about how slow it is to move to a tile
#for things like speed
static func tracePath(vector_map: Array, non_cumulative_weight_map: Array, start_loc: Vector2):
	var next_loc := [
		{
		"vector": vector_map[start_loc.x][start_loc.y],
		"weight": non_cumulative_weight_map[start_loc.x][start_loc.y],
		}
	]
	if (next_loc[0]["vector"] != start_loc):
		next_loc.append_array(tracePath(vector_map, non_cumulative_weight_map, next_loc[0]["vector"]))
	return next_loc
