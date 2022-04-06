class_name ReallyRandomFunctions

static func build_2d_array(x_len: int, y_len: int, initial_value):
	var arr := []
	
	for x in range(x_len):
		arr.append([])
		for y in range(y_len):
			arr[x].append(initial_value)
			
	return arr
