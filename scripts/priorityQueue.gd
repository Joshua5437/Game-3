extends Object

#a really unoptimal priority queue class
#hey, im lazy, sue me
class_name PriorityQueue

var _values := []
var _weights := []

func add_value(value, weight: int):
	var i = 0;
	#loops through current weights to place the new weight in the sorted position
	#from lowest to highest
	#depending on exactly how arrays are stored in godot, maybe should be reversed
	for num in _weights:
		if (num < weight):
			_values.insert(i, value)
			_weights.insert(i, weight)
			break
		i+=1
	_values.append(value)
	_weights.append(weight)
	


func pop_lowest():
	return {
		"value" : _values.pop_front(),
		"weight": _weights.pop_front(),
		
	}
func is_empty():
	return _values.size() == 0
